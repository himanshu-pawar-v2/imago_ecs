terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.9.0"
}
include "root"{
	path = find_in_parent_folders()
}

locals {
    // config = yamldecode(file("${find_in_parent_folders("config.yaml")}"))
    // config = yamldecode(file("${get_parent_terragrunt_dir()}/config.yaml"))
    config_path = "${get_parent_terragrunt_dir()}/config.yml"
    config = yamldecode(file(local.config_path))
}

output "resolved_config_path" {
    value = local.config_path
}

inputs = {
  name = local.config.vpc.name
  cidr = local.config.vpc.cdir
  azs             = local.azs
  private_subnets = local.config.vpc.private_subnets
  single_nat_gateway = local.config.vpc.single_nat_gateway
  public_subnets  = local.config.vpc.public_subnets
  enable_nat_gateway = local.config.vpc.enable_nat_gateway
  tags = local.config.vpc.tags
  map_public_ip_on_launch = local.config.vpc.map_public_ip_on_launch
  enable_nat_gateway = local.config.eks.deploy_worker_in_private_subnet 
}
