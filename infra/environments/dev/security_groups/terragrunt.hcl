include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/security_groups"
}

dependency "vpc" {
  config_path = "../vpc"   
  mock_outputs = {
    location = "mockOutput"
  }
}

inputs = {
  region       = "us-west-2"
  vpc_id       = dependency.vpc.outputs.vpc_id
  allowed_cidrs = ["0.0.0.0/0"]
  name_prefix  = "v2-boilerplate"
  environment  = "dev"
  owner = "ketha"
}
