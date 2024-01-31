

terraform {
  required_version = ">=1.0.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
    google-beta = {
      source  = "hashicorp/google"
      version = "5.14.0"
    }
  }

  backend "gcs" {
    bucket = "trace_terraform_perm_bucket"
    prefix = "gcp/lbs/internal-alb"
  }

}

