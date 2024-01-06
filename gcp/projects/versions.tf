terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.10.0"
    }
  }
  backend "gcs" {
    bucket = "trace-terraform-state-bucket"
    prefix = "gcp/networks/projects"
  }
}
