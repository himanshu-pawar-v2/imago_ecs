#!/bin/bash
set -e

RESOURCE_PREFIX=$1
ENVIRONMENT=$2
ACCOUNT_ID=$3

TAG_KEY="elbv2.k8s.aws/cluster"
TAG_VALUE="${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}"
echo "Fetching Load Balancer with tag ${TAG_KEY}:${TAG_VALUE}"

# Step 1: Fetch the load balancer ARN
LOAD_BALANCER_ARN=$(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn" --output text | while read -r arn; do
    aws elbv2 describe-tags --resource-arns "$arn" --query "TagDescriptions[?Tags[?Key=='${TAG_KEY}'&&Value=='${TAG_VALUE}']].ResourceArn" --output text
done)

if [ -z "$LOAD_BALANCER_ARN" ]; then
    echo "No Load Balancer found with the specified tag: ${TAG_KEY}:${TAG_VALUE}"
    exit 1
else
    LB_DNS=$(aws elbv2 describe-load-balancers --load-balancer-arns $LOAD_BALANCER_ARN --query "LoadBalancers[0].DNSName" --output text)
    echo "Load Balancer DNS: $LB_DNS"
fi

# Step 2: Find CloudFront Distribution with Environment tag set to production
distribution_ids=$(aws cloudfront list-distributions --query "DistributionList.Items[].Id" --output text)

for distribution_id in $distribution_ids; do
    tags=$(aws cloudfront list-tags-for-resource --resource "arn:aws:cloudfront::${ACCOUNT_ID}:distribution/$distribution_id" --query "Tags.Items[?Key=='Environment'].Value" --output text)
    
    if [[ "$tags" == "production" ]]; then
        echo "Found production distribution: $distribution_id"
        cloudfront_distribution_id=$distribution_id
        break
    fi
done

# Check if CloudFront distribution is found
if [ -z "$cloudfront_distribution_id" ]; then
    echo "Production CloudFront distribution not found."
    exit 1
fi

# Step 3: Update CloudFront Distribution to add Load Balancer DNS as an origin and update behavior
# Get the current CloudFront distribution config
distribution_config=$(aws cloudfront get-distribution-config --id "$cloudfront_distribution_id")

# Extract the ETag from the current distribution config
etag=$(echo $distribution_config | jq -r '.ETag')

# Extract the current distribution configuration JSON
distribution_config_json=$(echo $distribution_config | jq -r '.DistributionConfig')

# Create a new origin configuration for the load balancer
new_origin_id="custom-origin-$RANDOM"
new_origin=$(jq -n \
    --arg id "$new_origin_id" \
    --arg domain "$LB_DNS" \
    '{
        "Id": $id,
        "DomainName": $domain,
        "OriginPath": "",
        "CustomHeaders": {
            "Quantity": 0,
            "Items": []
        },
        "CustomOriginConfig": {
            "HTTPPort": 80,
            "HTTPSPort": 443,
            "OriginProtocolPolicy": "https-only",
            "OriginSslProtocols": {
                "Quantity": 1,
                "Items": ["TLSv1.2"]
            },
            "OriginReadTimeout": 30,
            "OriginKeepaliveTimeout": 5
        }
    }')

# Add the new origin to the existing origins in the distribution config
updated_config=$(echo $distribution_config_json | jq --argjson new_origin "$new_origin" '
    .Origins.Items += [$new_origin] |
    .Origins.Quantity = (.Origins.Items | length)
')

# Create a new cache behavior for the /backend path
new_cache_behavior=$(jq -n \
    --arg path_pattern "/backend/*" \
    --arg origin_id "$new_origin_id" \
    '{
        "PathPattern": $path_pattern,
        "TargetOriginId": $origin_id,
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {
                "Forward": "none"
            },
            "Headers": {
                "Quantity": 0,
                "Items": []
            },
            "QueryStringCacheKeys": {
                "Quantity": 0,
                "Items": []
            }
        },
        "TrustedSigners": {
            "Enabled": false,
            "Quantity": 0,
            "Items": []
        },
        "ViewerProtocolPolicy": "redirect-to-https",
        "MinTTL": 0,
        "DefaultTTL": 86400,
        "MaxTTL": 31536000,
        "Compress": true,
        "SmoothStreaming": false,
        "FieldLevelEncryptionId": "",
        "AllowedMethods": {
            "Quantity": 7,
            "Items": [
                "GET", "HEAD", "POST", "PUT", "PATCH", "OPTIONS", "DELETE"
            ],
            "CachedMethods": {
                "Quantity": 2,
                "Items": [
                    "GET", "HEAD"
                ]
            }
        }
    }')

# Add the new cache behavior to the existing cache behaviors
updated_config=$(echo $updated_config | jq --argjson new_cache_behavior "$new_cache_behavior" '
    .CacheBehaviors.Items += [$new_cache_behavior] |
    .CacheBehaviors.Quantity = (.CacheBehaviors.Items | length)
')

# Ensure FieldLevelEncryptionId is present in DefaultCacheBehavior
updated_config=$(echo $updated_config | jq '
    if .DefaultCacheBehavior.FieldLevelEncryptionId == null then
        .DefaultCacheBehavior.FieldLevelEncryptionId = ""
    else
        .
    end
')

# Apply the updated configuration to the CloudFront distribution
aws cloudfront update-distribution --id "$cloudfront_distribution_id" --if-match "$etag" --distribution-config "$(echo $updated_config | jq -c .)"

echo "Updated CloudFront distribution $cloudfront_distribution_id with new origin $LB_DNS and new behavior for /backend path"
# # Update the distribution config with the new origins
# updated_config=$(echo $distribution_config_json | jq --argjson updated_origins "$updated_origins" '.Origins = $updated_origins')

# # Apply the updated configuration to the CloudFront distribution
# aws cloudfront update-distribution --id "$cloudfront_distribution_id" --if-match "$etag" --distribution-config "$(echo $updated_config | jq -c .)"

# echo "Updated CloudFront distribution $cloudfront_distribution_id with new origin $LB_DNS"
