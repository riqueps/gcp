variable "gcp_project_id" {
    type = string
    description = "GCP Project ID"
}

variable "gcp_region" {
    type = string
    description = "GCP Region"
    default = "us-central1"
}

variable "env_name" {
    type = string
    description = "Env name"  
}