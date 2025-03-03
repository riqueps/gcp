# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  region = var.gcp_region
  project = var.gcp_project_id
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.21.0"
    }
  }
  backend "gcs" {
    bucket = "henrique-tf-state"
    prefix = "gke"
  }
}

module "gcp_base" {
  source = "../tf-modules/base"
  gcp_project_id = var.gcp_project_id
  gcp_region = var.gcp_region
  env_name = var.env_name
}

module "gcp_gke" {
  source = "../tf-modules/gke"
  gcp_project_id = var.gcp_project_id
  gcp_region = var.gcp_region
  env_name = var.env_name
  network = module.gcp_base.vpc.network_name
  pod_range = module.gcp_base.vpc.subnets_secondary_ranges[0][0].range_name
  service_range = module.gcp_base.vpc.subnets_secondary_ranges[0][1].range_name
  private_subnet_selflink = module.gcp_base.vpc.subnets_self_links[0]
}