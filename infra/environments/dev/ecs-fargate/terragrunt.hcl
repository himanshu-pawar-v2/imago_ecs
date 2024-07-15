# include {
#   path = find_in_parent_folders()
# }

# terraform {
#   source = "../../../terraform-modules/ecs-fargate"
# }

# inputs = {
#   cluster_name               = "my-ecs-cluster"
#   family                     = "my-task-family"
#   container_definitions_file = "${get_terragrunt_dir()}/../../container_definitions/ecs-container-definitions.json"
#   # container_definitions_file = "keth-poc-con/container_definitions.json"
#   execution_role_arn         = "arn:aws:iam::370180090626:role/execution-role"
#   task_role_arn              = "arn:aws:iam::370180090626:role/ecsTaskExecutionRole"
#   cpu                        = "256"
#   memory                     = "512"
#   service_name               = "my-ecs-service"
#   desired_count              = 1
#   subnets                    = ["subnet-0bc8c534294d2d30a", "subnet-0e5691db871dde039"]
#   security_groups            = ["sg-0e178f2f1eb92ecda"]
# }


terraform {
  source = "../../../modules/ecs-fargate"
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
  family                     = "v2-boilerplate-ecs-family"
  container_definitions_file = "${get_terragrunt_dir()}/../../../container_definitions/ecs-container-definitions.json"
  # container_definitions_file = "${get_terragrunt_dir()}/../../container_definitions/ecs_container_definitions.json"
  cpu                        = "256"
  memory                     = "512"
  service_name               = "v2-boilerplate-ecs-service"
  desired_count              = 2
  subnets                    = dependency.vpc.outputs.private_subnet_ids  #["subnet-12345678", "subnet-87654321"]
  ecs_security_group_ids     = [dependency.security_groups.outputs.vpc_security_group_ids]  #["sg-12345678", "sg-87654321"]
  environment                = "dev"
  owner                      = "KETHA"
  name_prefix                = "v2-boilerplate"
}
