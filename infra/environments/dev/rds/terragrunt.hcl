terraform {
  source = "tfr:///terraform-aws-modules/rds-aurora/aws?version=9.3.1"
}
include "root"{
	path = find_in_parent_folders()
}
locals {
  config = yamldecode(file("${find_in_parent_folders("config.yaml")}"))
}
dependency "network" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-03278703548834075"
    private_subnets = ["subnet-0cc4779eb49115236", "subnet-04be3ef94a742658c"]
  }
}
inputs = {
    name = local.config.rds.name
    engine         = local.config.rds.engine
    engine_version = local.config.rds.engine_version
    instance_class = local.config.rds.instance_class
    instances = local.config.rds.instances
    publicly_accessible    = local.config.rds.publicly_accessible
    vpc_id                 = dependency.network.outputs.vpc_id
    db_subnet_group_name   = local.config.rds.db_subnet_group_name
    subnets                = dependency.network.outputs.private_subnets
    create_db_subnet_group = local.config.rds.create_db_subnet_group    
    # security_group_rules = local.config.rds.security_group_rules
    database_name = local.config.rds.database_name
    master_username = local.config.rds.master_username
    storage_encrypted                                      = local.config.rds.storage_encrypted
    apply_immediately                                      = local.config.rds.apply_immediately
    monitoring_interval                                    = local.config.rds.monitoring_interval
    manage_master_user_password                            = local.config.rds.manage_master_user_password
    manage_master_user_password_rotation                   = local.config.rds.manage_master_user_password_rotation
    master_user_password_rotation_automatically_after_days = local.config.rds.master_user_password_rotation_automatically_after_days
    master_user_password_rotate_immediately = local.config.rds.master_user_password_rotate_immediately
    tags = local.config.rds.tags
}
