resource "google_compute_network" "this" {
  provider                        = google
  project                         = var.project
  name                            = var.vpc_name
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "this" {
  provider      = google
  count         = length(var.spoke_subnets)
  project       = var.project
  name          = "${var.vpc_name}-${var.spoke_subnets[count.index]}-subnet"
  ip_cidr_range = cidrsubnet(var.ip_block, 7, count.index)
  region        = var.region
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
  network       = google_compute_network.this.name
}

resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "${var.vpc_name}-l7-ilb-proxy-subnet"
  ip_cidr_range = cidrsubnet(var.ip_block, 8, 254)
  region        = var.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.this.name
  project       = var.project
}

resource "google_compute_firewall" "iap_access" {
  name    = "${var.vpc_name}-allow-iap-ssh-rdp-access"
  project = var.project
  network = google_compute_network.this.name
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
  source_ranges      = ["35.235.240.0/20"]
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["allow-iap-ssh-rdp"]
  direction          = "INGRESS"
}

resource "google_compute_firewall" "egress" {
  name    = "${var.vpc_name}-allow-all-egress"
  project = var.project
  network = google_compute_network.this.name
  allow {
    protocol = "all"
  }
  source_ranges      = [for subnets in google_compute_subnetwork.this : subnets.ip_cidr_range]
  destination_ranges = ["0.0.0.0/0"]
  direction          = "EGRESS"

}

resource "google_compute_firewall" "health_checks" {
  name               = "allow-all-lb-health-checks"
  network            = data.google_compute_network.app.self_link
  project            = var.project
  direction          = "INGRESS"
  priority           = 1000
  source_ranges      = ["35.191.0.0/16", "130.211.0.0/22"]
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  target_tags = ["allow-all-lb-hc"]
}

resource "google_compute_firewall" "allow_all" {
  name               = "allow-all"
  network            = data.google_compute_network.app.self_link
  project            = var.project
  direction          = "INGRESS"
  priority           = 1000
  source_ranges      = ["0.0.0.0/0"]
  destination_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
  target_tags = ["allow-all"]

}
output "network" {
  value = google_compute_network.this.self_link
}

variable "ip_block" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "spoke_subnets" {
  type = list(string)
}

terraform {
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
}
