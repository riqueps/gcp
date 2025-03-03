# apis
# https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest/submodules/project_services
module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.0"

  project_id                  = var.gcp_project_id
  disable_services_on_destroy = false

  activate_apis = [
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "binaryauthorization.googleapis.com",
    "stackdriver.googleapis.com",
    "iap.googleapis.com",
    "cloudkms.googleapis.com",
  ]
}

# compute metadata
resource "google_compute_project_metadata" "default" {
  metadata = {
    block-project-ssh-keys  = "TRUE"
    enable-guest-attibutes = "TRUE"
    enable-os-config = "TRUE"
    enable-os-login = "TRUE"
  }
}