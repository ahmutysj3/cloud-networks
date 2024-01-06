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

resource "google_compute_route" "this" {
  depends_on  = [google_compute_subnetwork.this]
  count       = var.vpc == "trusted" ? 1 : 0
  project     = data.google_client_config.this.project
  name        = "default-fw-route"
  network     = google_compute_network.this.name
  dest_range  = "0.0.0.0/0"
  next_hop_ip = cidrhost(var.ip_block, 2)
  priority    = 1
}

resource "google_compute_subnetwork" "this" {
  project       = data.google_client_config.this.project
  name          = "${var.vpc}-subnet"
  ip_cidr_range = var.ip_block
  region        = data.google_client_config.this.region
  network       = google_compute_network.this.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

module "cloud_router" {
  source   = "./cloud-router"
  count    = var.router ? 1 : 0
  vpc_name = var.vpc
  network  = google_compute_network.this.name
}

data "google_compute_zones" "available" {
  project = data.google_client_config.this.project
  region  = data.google_client_config.this.region
}

data "google_client_config" "this" {
}

variable "ip_block" {
  type = string
}

variable "router" {
  type = bool
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

