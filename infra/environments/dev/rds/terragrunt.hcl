terraform {
  source = "../../../modules/rds"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"   
  mock_outputs = {
    location = "mockOutput"
  }
}

dependency "security_groups" {
  config_path = "../security_groups"
  mock_outputs = {
    location = "mockOutput"
  }
}

inputs = {
  db_name      = "v2-boilerplate"
  subnet_ids   = dependency.vpc.outputs.private_subnet_ids
  vpc_id       = dependency.vpc.outputs.vpc_id
  vpc_security_group_ids = [dependency.security_groups.outputs.vpc_security_group_ids]
  environment  = "dev"
  owner        = "KETHA"
  name_prefix  = "v2-boilerplate"
}



