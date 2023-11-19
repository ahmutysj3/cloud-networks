resource "google_compute_router" "untrusted" {
  name    = "trace-untrusted-cloud-router"
  region  = var.gcp_region
  project = var.gcp_project
  network = google_compute_network.untrusted.name
}

resource "google_compute_router_nat" "untrusted" {
  name                               = "${google_compute_router.untrusted.name}-nat"
  router                             = google_compute_router.untrusted.name
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


resource "google_compute_router" "mgmt" {
  name    = "trace-mgmt-cloud-router"
  region  = var.gcp_region
  project = var.gcp_project
  network = google_compute_network.mgmt.name
}

resource "google_compute_router_nat" "mgmt" {
  name                               = "${google_compute_router.mgmt.name}-nat"
  router                             = google_compute_router.mgmt.name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.mgmt.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
