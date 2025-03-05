# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  region  = var.gcp_region
  project = var.gcp_project_id
}

terraform {
  backend "gcs" {
    bucket = "henrique-tf-state"
    prefix = "gke-base"
  }
}

module "gcp_base" {
  source         = "../../tf-modules/base"
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  environment    = var.environment
}
