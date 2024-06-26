terraform {

  required_version = "1.6.3"
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

  backend "gcs" {
    bucket = "trace_terraform_perm_bucket"
    prefix = "gcp/networks/edge"
  }
}



