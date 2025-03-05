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

variable "network" {
  type        = string
  description = "GCP VPC Network"
}

variable "private_subnet_selflink" {
  type        = string
  description = "Private subnet selflink"
}

variable "pod_range" {
  type        = string
  description = "POD ip range"
}

variable "service_range" {
  type        = string
  description = "Service ip range"
}