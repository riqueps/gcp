resource "google_compute_instance" "vm1" {
  for_each = var.gcp_vms_map

  name                      = "vm-${each.value.name}"
  machine_type              = "e2-micro"
  zone                      = "us-central1-a"
  allow_stopping_for_update = true # permit terraform stop instance to update
  network_interface {
    network    = module.vpc.network_name
    subnetwork = each.value.subnet

  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  depends_on = [module.vpc]
}