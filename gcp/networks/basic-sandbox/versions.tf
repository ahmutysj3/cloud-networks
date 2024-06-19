terraform {

  required_version = "1.6.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=5.9"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">=5.9"
    }
  }

  cloud {
    organization = "ahmutysj3"

    workspaces {
      name = "gcp-networks-basic-sandbox"
    }
  }
  /* backend "gcs" {
    bucket = "trace_terraform_perm_bucket"
    prefix = "gcp/networks/basic"
  } */
}

provider "google" {
  project = var.project
  region  = var.region

}

provider "google-beta" {
  project = var.project
  region  = var.region

}




