terraform {
  required_version = ">= 1.3, < 2.0"

  backend "gcs" {
    bucket = "trace_terraform_perm_bucket"
    prefix = "gcp/instances/panorama"
  }
}

provider "google" {
  project = var.project
  region  = var.region
}