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
      version = ">=3.79.0"
    }
  }
}
