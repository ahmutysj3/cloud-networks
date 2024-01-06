data "google_client_config" "this" {
}

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
