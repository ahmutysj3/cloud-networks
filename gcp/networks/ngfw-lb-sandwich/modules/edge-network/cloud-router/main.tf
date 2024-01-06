# Creates a Cloud Router for the untrusted network
resource "google_compute_router" "this" {
  name    = "${var.vpc_name}-cloud-router"
  region  = data.google_client_config.this.region
  project = data.google_client_config.this.project
  network = var.network
}

# Creates a Cloud Router for the untrusted network
resource "google_compute_router_nat" "this" {
  name                               = "${google_compute_router.this.name}-nat"
  router                             = google_compute_router.this.name
  region                             = google_compute_router.this.region
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  log_config {
    enable = var.log_config.enable
    filter = var.log_config.filter
  }
}

variable "vpc_name" {
  type = string
}

variable "network" {
  type = string
}


data "google_client_config" "this" {
}


variable "nat_ip_allocate_option" {
  type    = string
  default = "AUTO_ONLY"
}

variable "source_subnetwork_ip_ranges_to_nat" {
  type    = string
  default = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "log_config" {
  type = map(string)
  default = {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
