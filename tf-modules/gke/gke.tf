data "google_project" "main" {
  project_id = var.gcp_project_id
}

data "google_client_config" "default" {}

# gke service account
resource "google_service_account" "service_account" {
  account_id   = "${var.environment}-gke-sa"
  display_name = "GKE Service Account"
}

# random string for key ring
resource "random_string" "random" {
  length  = 5
  special = false
  lower   = true
}

# kms
# https://registry.terraform.io/modules/terraform-google-modules/kms/google/latest
module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 4.0"

  project_id           = var.gcp_project_id
  key_protection_level = "HSM"
  location             = var.gcp_region
  keyring              = "${var.environment}-keyring-${random_string.random.result}"
  keys                 = ["gke-key"]
  prevent_destroy      = false
}

# grant encrypt/decrypt permission for GKE service
resource "google_kms_crypto_key_iam_binding" "main" {
  crypto_key_id = values(module.kms.keys)[0]
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:service-${data.google_project.main.number}@container-engine-robot.iam.gserviceaccount.com",
    "serviceAccount:service-${data.google_project.main.number}@compute-system.iam.gserviceaccount.com",
    "serviceAccount:${var.environment}-gke-sa@${var.gcp_project_id}.iam.gserviceaccount.com"
  ]
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# gke 
# https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  version = "~> 36.0.2"

  project_id                 = var.gcp_project_id
  name                       = "${var.environment}-gke-cluster"
  region                     = var.gcp_region
  zones                      = ["us-central1-a", "us-central1-b"]
  network                    = var.network
  subnetwork                 = "private"
  ip_range_pods              = var.pod_range
  ip_range_services          = var.service_range
  release_channel            = "REGULAR"
  grant_registry_access      = true
  enable_private_nodes       = true
  enable_private_endpoint    = true
  deletion_protection        = false
  dns_cache                  = false
  create_service_account     = false
  service_account            = google_service_account.service_account.email
  boot_disk_kms_key          = values(module.kms.keys)[0]
  horizontal_pod_autoscaling = true

  master_authorized_networks = [{
    cidr_block   = "${module.bastion.ip_address}/32"
    display_name = "Private access"
  }]

  database_encryption = [
    {
      "key_name" : module.kms.keys["gke-key"],
      "state" : "ENCRYPTED"
    }
  ]

  depends_on = [module.kms, google_kms_crypto_key_iam_binding.main]
}