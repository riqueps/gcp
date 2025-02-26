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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  backend "gcs" {
    bucket = "henrique-tf-state"
    prefix = "gke"
  }
}