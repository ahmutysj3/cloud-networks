resource "google_compute_network" "this" {
  provider                        = google
  name                            = "${var.vpc}-vpc"
  project                         = data.google_client_config.this.project
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}


resource "google_compute_firewall" "ingress" {
  provider      = google
  name          = "default-allow-all-ingress-${var.vpc}"
  project       = var.project
  network       = google_compute_network.this.name
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "egress" {
  provider           = google
  name               = "default-allow-all-egress-${var.vpc}"
  project            = var.project
  network            = google_compute_network.this.name
  priority           = 1000
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

data "google_compute_zones" "available" {
  project = data.google_client_config.this.project
  region  = data.google_client_config.this.region
}

data "google_client_config" "this" {
}

output "google_client_config" {
  value = data.google_client_config.this

}

variable "ip_block" {
  type = string

}

variable "project" {
  type = string
}

variable "vpc" {
  type = string
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

