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
