#!/usr/bin/env bash

set -e

RESOURCE_PREFIX=$1
ENVIRONMENT=$2
ACCOUNT_ID=$3

echo "Fetching Load Balancer with tag elbv2.k8s.aws/cluster:${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}"
LB_DNS=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(Tags[?Key=='elbv2.k8s.aws/cluster'].Value, '${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}')].DNSName" --output text)
echo "Load Balancer DNS: $LB_DNS"

DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?Comment=='${ENVIRONMENT}'].Id" --output text)
if [ -z "$DISTRIBUTION_ID" ]; then
  echo "CloudFront distribution not found for environment: ${ENVIRONMENT}"
  exit 1
fi
echo "Found distribution ID: ${DISTRIBUTION_ID}"

DISTRIBUTION_CONFIG=$(aws cloudfront get-distribution-config --id $DISTRIBUTION_ID)
ETAG=$(echo $DISTRIBUTION_CONFIG | jq -r '.ETag')
ORIGINAL_CONFIG=$(echo $DISTRIBUTION_CONFIG | jq -r '.DistributionConfig')

UPDATED_CONFIG=$(echo $ORIGINAL_CONFIG | jq --arg LB_DNS "$LB_DNS" '.Origins = {
  "Quantity": 1,
  "Items": [
    {
      "Id": "custom-origin",
      "DomainName": $LB_DNS,
      "OriginPath": "",
      "CustomHeaders": {
        "Quantity": 0
      },
      "S3OriginConfig": {
        "OriginAccessIdentity": ""
      },
      "CustomOriginConfig": {
        "HTTPPort": 80,
        "HTTPSPort": 443,
        "OriginProtocolPolicy": "https-only",
        "OriginSslProtocols": {
          "Quantity": 1,
          "Items": [
            "TLSv1.2"
          ]
        },
        "OriginReadTimeout": 30,
        "OriginKeepaliveTimeout": 5
      }
    }
  ]
}')

echo "Updating CloudFront distribution: ${DISTRIBUTION_ID}"
aws cloudfront update-distribution --id $DISTRIBUTION_ID --distribution-config "$UPDATED_CONFIG" --if-match $ETAG


# #!/bin/bash
# set -e

# RESOURCE_PREFIX=$1
# ENVIRONMENT=$2
# ACCOUNT_ID=$3

# TAG_KEY="elbv2.k8s.aws/cluster"
# TAG_VALUE="${RESOURCE_PREFIX}-cluster-${ENVIRONMENT}"
# echo "Fetching Load Balancer with tag ${TAG_KEY}:${TAG_VALUE}"

# # Step 1: Fetch the load balancer ARN
# LOAD_BALANCER_ARN=$(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn" --output text | while read -r arn; do aws elbv2 describe-tags --resource-arns "$arn" --query "TagDescriptions[?Tags[?Key=='${TAG_KEY}'&&Value=='${TAG_VALUE}']].ResourceArn" --output text; done)

# if [ -z "$LOAD_BALANCER_ARN" ]; then
#     echo "No Load Balancer found with the specified tag: ${TAG_KEY}:${TAG_VALUE}"
#     exit 1
# else 
#     LB_DNS=$(aws elbv2 describe-load-balancers --load-balancer-arns $LOAD_BALANCER_ARN --query "LoadBalancers[0].DNSName" --output text)
#     echo "Load Balancer DNS: $LB_DNS"
# fi

# # Step 2: Find CloudFront Distribution with Environment tag set to production
# distribution_ids=$(aws cloudfront list-distributions --query "DistributionList.Items[].Id" --output text)

# for distribution_id in $distribution_ids; do
#     tags=$(aws cloudfront list-tags-for-resource --resource "arn:aws:cloudfront::${ACCOUNT_ID}:distribution/$distribution_id" --query "Tags.Items[?Key=='Environment'].Value" --output text)
    
#     if [[ "$tags" == "production" ]]; then
#         echo "Found production distribution: $distribution_id"
#         cloudfront_distribution_id=$distribution_id
#         break
#     fi
# done

# # Check if CloudFront distribution is found
# if [ -z "$cloudfront_distribution_id" ]; then
#     echo "Production CloudFront distribution not found."
#     exit 1
# fi

# # Step 3: Update CloudFront Distribution to add Load Balancer DNS as an origin
# # Get the current CloudFront distribution config
# distribution_config=$(aws cloudfront get-distribution-config --id "$cloudfront_distribution_id")

# # Extract the ETag from the current distribution config
# etag=$(echo $distribution_config | jq -r '.ETag')

# # Extract the current distribution configuration JSON
# distribution_config_json=$(echo $distribution_config | jq -r '.DistributionConfig')

# # Create a new origin configuration for the load balancer
# new_origin=$(jq -n \
#     --arg id "custom-origin-$RANDOM" \
#     --arg domain "$LB_DNS" \
#     '{
#         "Id": $id,
#         "DomainName": $domain,
#         "OriginPath": "",
#         "CustomHeaders": {
#             "Quantity": 0,
#             "Items": []
#         },
#         "CustomOriginConfig": {
#             "HTTPPort": 80,
#             "HTTPSPort": 443,
#             "OriginProtocolPolicy": "https-only",
#             "OriginSslProtocols": {
#                 "Quantity": 1,
#                 "Items": ["TLSv1.2"]
#             },
#             "OriginReadTimeout": 30,
#             "OriginKeepaliveTimeout": 5
#         }
#     }')

# # Add the new origin to the existing origins in the distribution config
# updated_origins=$(echo $distribution_config_json | jq ".Origins.Items += [$new_origin] | .Origins.Quantity += 1")

# # Update the distribution config with the new origins
# updated_config=$(echo $distribution_config_json | jq ".Origins = $updated_origins")

# # Apply the updated configuration to the CloudFront distribution
# aws cloudfront update-distribution --id "$cloudfront_distribution_id" --if-match "$etag" --distribution-config "$(echo $updated_config | jq -c .)"

# echo "Updated CloudFront distribution $cloudfront_distribution_id with new origin $LB_DNS"