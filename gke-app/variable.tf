variable "gcp_project_id" {
  type        = string
  description = "GCP Projecto ID"
}

variable "gcp_region" {
  type        = string
  description = "GCP Region"
}

variable "environment" {
  type        = string
  description = "Env Name (sample, dev, test, ...)"
}
