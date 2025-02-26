variable "gcp_project_id" {
  type = string
  description = "GCP Projecto ID"
}

variable "gcp_region" {
  type = string
  description = "GCP Region"
}

variable "env_name" {
  type = string
  description = "Env Name (sample, dev, test, ...)"
}

# variable "gke_endpoint" {
#   type = string
#   description = "GKE Endpoint"
# }

# variable "gke_ca_certificate" {
#   type = string
#   description = "GKE CA Certificate"
# }