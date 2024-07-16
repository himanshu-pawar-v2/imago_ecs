terraform {
  backend "s3" {
    bucket = "v2-boilerplate-s3-state"
    key = "eks/terraform.tfstate"
    region = "us-west-2"
  }
}