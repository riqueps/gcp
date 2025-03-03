#  TCP ingress traffic from the IP range 35.235.240.0/20, port: 22

#  gcloud compute 
#  --project=semiotic-ion-451513-i3 
#  firewall-rules create iap 
#  --direction=INGRESS 
#  --priority=1000 
#  --network=sample-vpc 
#  --action=ALLOW 
#  --rules=tcp:22 
#  --source-ranges=35.235.240.0/20

 resource "google_compute_firewall" "iap" {
    project = var.gcp_project_id
    name    = "iap-${var.env_name}"
    network = module.vpc.network_name
    description = "Allow IAP login for VMs"

    allow {
        protocol = "tcp"
        ports    = ["22"]
    }
    source_ranges = ["35.235.240.0/20"]
 }