terraform {
  source = "../../../infra-modules/s3_bucket_policy"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  config_path = "${get_terragrunt_dir()}/../config.yml"
  config = yamldecode(file(local.config_path))
}

dependency "s3" {
  config_path = "../s3"
}

dependency "cloudfront" {
  config_path = "../cloudfront"
}

inputs = {
  bucket_name = dependency.s3.outputs.s3_bucket_name
  cloudfront_distribution_id = dependency.cloudfront.outputs.cloudfront_distribution_id
}

// terraform {
//     source = "../../../infra-modules/s3_bucket_policy"
// }

// include "root"{
//     path = find_in_parent_folders()
// }

// // include "env"{
// //     path = find_in_parent_folders("env.hcl")
// //     expose = true
// //     merge_strategy = "no_merge"
// // }

// locals {
//     // config = yamldecode(file("${find_in_parent_folders("config.yaml")}"))
//     // config = yamldecode(file("${get_parent_terragrunt_dir()}/config.yaml"))
//     config_path = "${get_terragrunt_dir()}/../config.yml"
//     config = yamldecode(file(local.config_path))
// }

// inputs = {
// 	// env = include.env.locals.env
//     bucket_name = local.config.s3.bucket_name
//     cloudfront_distribution_id = dependency.cloudfront.outputs.cloudfront_distribution_id
// }

// dependency "cloudfront"{
// 	config_path = "../cloudfront"

// 	mock_outputs ={
// 	    cloudfront_distribution_id = "E1234567891011"
// 	}
// }

// dependency "s3"{
// 	config_path = "../s3"
// 	mock_outputs ={
// 	    s3_bucket_name = local.config.s3.bucket_name
// 	}
// }
