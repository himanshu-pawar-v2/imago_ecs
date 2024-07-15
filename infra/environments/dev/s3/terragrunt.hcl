terraform {
    source = "../../../infra-modules/s3"
}

include "root"{
    path = find_in_parent_folders()
}

locals {
    // config = yamldecode(file("${find_in_parent_folders("config.yaml")}"))
    // config = yamldecode(file("${get_parent_terragrunt_dir()}/config.yaml"))
    config_path = "${get_terragrunt_dir()}/../config.yml"
    // config_path = "${get_parent_terragrunt_dir()}/config.yml"
    config = yamldecode(file(local.config_path))
}

// include "env"{
//     path = find_in_parent_folders("env.hcl")
//     expose = true
//     merge_strategy = "no_merge"
// }

inputs = {
    // env = include.env.locals.env
    // bucket_name = "${get_env("RESOURCE_PREFIX", "")}-${local.config.s3.bucket_name}"
    bucket_name = local.config.s3.bucket_name
    // bucket_name = "v2-boilerplate-sagar-dev"
    versioning_enabled = local.config.s3.versioning_enabled
}
