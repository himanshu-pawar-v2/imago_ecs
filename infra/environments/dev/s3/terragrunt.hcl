terraform {
    source = "../../../infra-modules/s3"
}

include "root"{
    path = find_in_parent_folders()
}

include "env"{
    path = find_in_parent_folders("env.hcl")
    expose = true
    merge_strategy = "no_merge"
}

inputs = {
    env = include.env.locals.env
    bucket_name = "${get_env("RESOURCE_PREFIX", "")}-s3-${get_env("ENVIRONMENT", "")}"
    // bucket_name = "v2-boilerplate-sagar-dev"
    versioning_enabled = false
}
