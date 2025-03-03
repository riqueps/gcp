# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
  region  = var.gcp_region
  project = var.gcp_project_id
}

# # https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer
# resource "random_integer" "int" {
#   min = 100
#   max = 1000000
# }

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
    prefix = "vm"
  }
}