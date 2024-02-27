terraform {
  required_version = "= 1.3.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.66.0"
    }
  }
}

provider "google" {
  project = var.config.project_id
  region  = var.config.region
}