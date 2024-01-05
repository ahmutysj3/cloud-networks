variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "web_subnets" {
  type = list(string)
}

variable "network" {
  type = string
}

variable "vpc" {
  type = string
}

variable "ip_block" {
  type = string
}

resource "google_compute_subnetwork" "web" {
  count         = length(var.web_subnets)
  project       = var.project
  name          = "${var.vpc}-${var.web_subnets[count.index]}-web-subnet"
  ip_cidr_range = cidrsubnet(var.ip_block, 7, count.index)
  region        = var.region
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
  network       = var.network
}

resource "google_compute_subnetwork" "proxy" {
  project       = var.project
  name          = "${var.vpc}-proxy-subnet"
  ip_cidr_range = cidrsubnet(var.ip_block, 7, 255)
  region        = var.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  network       = var.network
  role          = "ACTIVE"
}

resource "google_compute_subnetwork" "ilb" {
  name          = "${var.vpc}-ilb-subnet"
  project       = var.project
  ip_cidr_range = cidrsubnet(var.ip_block, 7, 100)
  region        = var.region
  network       = var.network
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}
