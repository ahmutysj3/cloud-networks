terraform {
  required_version = ">=1.3.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.66.0"
    }
  }
  backend "gcs" {
    bucket = "trace_terraform_perm_bucket"
    prefix = "gcp/lab/palo-ha"
  }

}

provider "google" {
  project = var.config.project_id
  region  = var.config.region
}
