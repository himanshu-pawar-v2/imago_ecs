# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "v2-boilerplate-state"
    dynamodb_table = "v2-boilerplate-state-lock-table"
    encrypt        = true
    key            = "./terraform.tfstate"
    region         = "us-west-2"
  }
}
