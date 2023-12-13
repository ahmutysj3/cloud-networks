terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.9"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}



