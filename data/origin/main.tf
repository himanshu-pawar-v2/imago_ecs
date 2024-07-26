data "aws_cloudfront_distribution" "this" {
  id = var.cloudfront_id
}
variable "cloudfront_id" {
  type = string
  default = "ED624DSHBWHY2"
}
variable "loadblancer" {
  type = string
  default = "application-ingress-611765166.us-west-2.elb.amazonaws.com"
}
resource "aws_cloudfront_origin_access_control" "example" {
  name                              = "example"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}