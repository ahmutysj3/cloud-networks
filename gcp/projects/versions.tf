terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.10.0"
    }
  }
  backend "gcs" {
    bucket = "trace_terraform_perm_bucket"
    prefix = "gcp/projects"
  }
}
