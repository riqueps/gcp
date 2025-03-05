locals {
  private_cidr = var.gcp_subnet_cidrs[0].private
  public_cidr  = var.gcp_subnet_cidrs[0].public
}

# vpc
# https://registry.terraform.io/modules/terraform-google-modules/network/google/
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"

  project_id   = var.gcp_project_id
  network_name = "${var.environment}-vpc"

  subnets = [
    {
      subnet_name           = "public"
      subnet_ip             = local.public_cidr
      subnet_region         = var.gcp_region
      stack_type            = "IPV4_ONLY"
      subnet_private_access = "false"
      subnet_flow_logs      = "false"
    },
    {
      subnet_name           = "private"
      subnet_ip             = local.private_cidr
      subnet_region         = var.gcp_region
      stack_type            = "IPV4_ONLY"
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
    }
  ]
  secondary_ranges = {}
}

# cloud router and cloud nat
# https://registry.terraform.io/modules/terraform-google-modules/cloud-router/google/
module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.2"

  name   = "${var.environment}-cloud-router"
  region = var.gcp_region

  project = var.gcp_project_id
  network = module.vpc.network_name

  bgp = {
    asn = "65001"
  }

  nats = [{
    name                               = "${var.environment}-nat-gateway"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    # nat_ip_allocate_option = "AUTO_ONLY"
    # To assign a reserved IP
    nat_ip_allocate_option = "MANUAL_ONLY"
    nat_ips                = ["${resource.google_compute_address.egress_ip.self_link}"]
    subnetworks = [
      {
        name                    = module.vpc.subnets["${var.gcp_region}/private"].id
        source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
      }
    ]
    log_config = {
      enable = false
    }
  }]
}

# Reserve public IP
resource "google_compute_address" "egress_ip" {
  name         = "${var.environment}-egress-ip"
  project      = var.gcp_project_id
  address_type = "EXTERNAL"
}