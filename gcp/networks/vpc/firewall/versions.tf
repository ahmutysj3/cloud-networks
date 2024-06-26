terraform {
  required_version = ">=1.3.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=5.10.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">=5.10.0"
    }
  }
  backend "gcs" {
    bucket = "trace_terraform_perm_bucket"
    prefix = "gcp/networks/firewall"
  }
}

provider "google" {
}

provider "google-beta" {
}
