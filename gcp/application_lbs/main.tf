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

provider "google" {
  project = var.project
  region  = var.region
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

/* resource "google_compute_instance_group" "this" {
  name = "web-ig0"
  zone =
  network =
} */


/* data "google_compute_instance" "this" {
  name = 
} */
