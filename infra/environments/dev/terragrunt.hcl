# terraform {
#   source = "git::ssh://git@github.com/v2-accelerators/ecs-poc-3-tier.git//infrastructure/modules"
# }

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "ketha-s3"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    #key    = "infra/terraform.tfstate"
    region = "us-west-2"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-west-2"
}
EOF
}
