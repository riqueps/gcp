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

variable "private_subnet_name" {
  type = string
  description = "Private subnet name"
}

variable "public_subnet_name" {
  type = string
  description = "Public subnet name"
}