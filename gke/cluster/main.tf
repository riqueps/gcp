# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  region  = var.gcp_region
  project = var.gcp_project_id
}

terraform {
  backend "gcs" {
    bucket = "henrique-tf-state"
    prefix = "gke-cluster"
  }
}

module "gcp_gke" {
  source                  = "../../tf-modules/gke"
  gcp_project_id          = var.gcp_project_id
  gcp_region              = var.gcp_region
  environment             = var.environment
  network                 = data.terraform_remote_state.vpc.outputs.vpc.network_name
  pod_range               = data.terraform_remote_state.vpc.outputs.vpc.subnets_secondary_ranges[0][0].range_name
  service_range           = data.terraform_remote_state.vpc.outputs.vpc.subnets_secondary_ranges[0][1].range_name
  private_subnet_selflink = data.terraform_remote_state.vpc.outputs.vpc.subnets_self_links[0]
}