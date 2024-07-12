terraform {
  source = "../../../additional_modules/helm"
}
include "root"{
	path = find_in_parent_folders()
}
locals {
  config = yamldecode(file("${find_in_parent_folders("config.yaml")}"))
}

dependency "ebs" {
  config_path = "../ebs"
  mock_outputs = {
    oidc_provider = ""
  }
}
inputs = {
  cluster_name = local.config.eks.cluster_name
  deployment_name = local.config.prometheus.deployment_name
  repository_link = local.config.prometheus.repository_link
  chart_name = local.config.prometheus.chart_name
  values = ["${file("${find_in_parent_folders("${local.config.prometheus.config_file}")}")}"]
}