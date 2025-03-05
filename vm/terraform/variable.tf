variable "gcp_project_id" {
  type        = string
  description = "GCP Projecto ID"
}

variable "gcp_region" {
  type        = string
  description = "GCP Region"
}

variable "gcp_az" {
  type    = list(string)
  default = ["us-central1-a"]
}

variable "environment" {
  type        = string
  description = "Env Name (sample, dev, test, ...)"
}

variable "gcp_subnet_cidrs" {
  type = list(object({
    private = string
    public  = string
  }))
  description = "GCP subnet names"
  default = [{
    public  = "10.10.10.0/24"
    private = "10.10.20.0/24"
  }]
}

variable "gcp_vms_map" {
  type = map(object({
    name   = string
    subnet = string
  }))
  description = "Map of VMs"
  default = {
    "vm1" = {
      name   = "01"
      subnet = "private"
    }
    "vm2" = {
      name   = "02"
      subnet = "public"
    }
  }
}