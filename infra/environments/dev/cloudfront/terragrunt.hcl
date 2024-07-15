terraform {
    source = "../../../infra-modules/cloudfront"
}

include "root"{
    path = find_in_parent_folders()
}

// include "env"{
//     path = find_in_parent_folders("env.hcl")
//     expose = true
//     merge_strategy = "no_merge"
// }

locals {
    // config = yamldecode(file("${find_in_parent_folders("config.yaml")}"))
    config_path = "${get_terragrunt_dir()}/../config.yml"
    // config_path = "/home/runner/work/v2-boilerplate-microservices-application/v2-boilerplate-microservices-application/infra/environments/dev/config.yml"
    // config = yamldecode(file("${get_parent_terragrunt_dir()}/config.yaml"))
    // config_path = "${get_parent_terragrunt_dir()}/config.yml"
    // config_path = "${path_relative_from_include()}/../../config.yml"
    config = yamldecode(file(local.config_path))
}

output "resolved_config_path" {
    value = local.config_path
}

inputs = {
    // env = include.env.locals.env
    bucket_name = dependency.s3.outputs.s3_bucket_name
}

dependency "s3"{
	config_path = "../s3"

	mock_outputs ={
	    s3_bucket_name = "my-test-bucket"
	}
}
