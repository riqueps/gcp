resource "google_compute_instance" "vm1" {
  name         = "${local.env_name}-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  network_interface {
    network = module.vpc.network_name
    subnetwork = local.private_subnet_name
    
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  depends_on = [ module.vpc ]
}