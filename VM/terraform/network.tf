# vpc
# https://registry.terraform.io/modules/terraform-google-modules/network/google/
module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 10.0"

    project_id   = local.project_id
    network_name = "${local.env_name}-vpc"

    subnets = [
        {
            subnet_name = local.public_subnet_name
            subnet_ip   = "10.10.10.0/24"
            subnet_region = local.region
            stack_type = "IPV4_ONLY"
            subnet_private_access = "false"
            subnet_flow_logs      = "false"
        },
        {
            subnet_name = local.private_subnet_name
            subnet_ip   = "10.10.20.0/24"
            subnet_region = local.region
            stack_type = "IPV4_ONLY"
            subnet_private_access = "true"
            subnet_flow_logs      = "false"
        }
    ]
    secondary_ranges = {
    (local.private_subnet_name) = [
      {
        range_name    = "gke-pods"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "gke-services"
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

# cloud router and cloud nat
# https://registry.terraform.io/modules/terraform-google-modules/cloud-router/google/
module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.2"

  name    = "${local.env_name}-cloud-router"
  region  = local.region

  project = local.project_id
  network = module.vpc.network_name
  
  bgp = {
    asn = "65001"
  }

  nats = [{
    name                               = "${local.env_name}-nat-gateway"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    # nat_ip_allocate_option = "AUTO_ONLY"
    # To assign a reserved IP
    nat_ip_allocate_option             = "MANUAL_ONLY"
    nat_ips                            = ["${resource.google_compute_address.egress_ip.self_link}"]
    subnetworks = [
      {
        name                     = module.vpc.subnets["${local.region}/${local.private_subnet_name}"].id
        source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE"]
      }
    ]
    log_config = {
        enable = false
    }
  }]
}

# Reserve public IP
resource "google_compute_address" "egress_ip" {
  name = "${local.env_name}-egress-ip"
  project = local.project_id
  address_type = "EXTERNAL"
}