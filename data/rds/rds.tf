terraform {
  backend "s3" {
    bucket = "v2-sbp-s3-state"
    key = "rds/terraform.tfstate"
    region = "us-west-2"
  }
}