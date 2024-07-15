terraform {
  source = "../../../modules/ecr" 
}

include {
  path = find_in_parent_folders()
}

inputs = {
  region = "us-west-2"
  repository_name = "v2-boilerplate-repo"
}
