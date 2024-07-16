terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
  }
}

provider "google" {
  project = var.vm_project
  region  = var.gcp_region
}
