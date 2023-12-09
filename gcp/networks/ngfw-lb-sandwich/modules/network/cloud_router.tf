# Creates a Cloud Router for the untrusted network
resource "google_compute_router" "untrusted" {
  count   = var.cloud_nat_enabled ? 1 : 0
  name    = "trace-untrusted-cloud-router"
  region  = var.gcp_region
  project = var.gcp_project
  network = google_compute_network.untrusted.name
}

# Creates a Cloud Router for the untrusted network
resource "google_compute_router_nat" "untrusted" {
  count                              = var.cloud_nat_enabled ? 1 : 0
  name                               = "${google_compute_router.untrusted[0].name}-nat"
  router                             = google_compute_router.untrusted[0].name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.untrusted.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

