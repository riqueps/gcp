/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# locals {
#   bastion_name = format("%s-bastion", var.cluster_name)
#   bastion_zone = format("%s-a", var.region)
# }

module "bastion" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "~> 8.0"

  network        = var.network
  subnet         = var.private_subnet_selflink
  project        = var.gcp_project_id
  host_project   = var.gcp_project_id
  name           = "${var.environment}-bastion"
  zone           = "us-central1-a"
  image_project  = "debian-cloud"
  machine_type   = "e2-micro"
  startup_script = templatefile("${path.module}/bastion.tftpl", {})
  #   members        = var.bastion_members
  shielded_vm = "false"

  #   service_account_roles = ["roles/container.viewer"]
}