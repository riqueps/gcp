variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "semiotic-ion-451513-i3"
}

variable "gcp_region" {
  type        = string
  description = "GCP Region"
  default     = "us-central1"
}

variable "environment" {
  type        = string
  description = "Env name"
  default     = "sample"
}