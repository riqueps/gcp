data "terraform_remote_state" "vpc" {
  backend   = "gcs"
  workspace = terraform.workspace

  config = {
    bucket = "henrique-tf-state"
    prefix = "gke-base"
  }
}
