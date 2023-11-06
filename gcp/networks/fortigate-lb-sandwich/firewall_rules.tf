resource "google_compute_firewall" "untrusted" {
  name      = "default-allow-all-untrusted"
  project   = var.gcp_project
  network   = google_compute_network.untrusted.name
  priority  = 1000
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "trusted" {
  name      = "default-allow-all-trusted"
  project   = var.gcp_project
  network   = google_compute_network.trusted.name
  priority  = 1000
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "protected" {
  name      = "allow-all-from-trusted-to-protected"
  project   = var.gcp_project
  network   = google_compute_network.protected.name
  priority  = 1000
  direction = "INGRESS"

  source_ranges = [google_compute_subnetwork.trusted.ip_cidr_range]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "health_checks" {
  name      = "default-allow-health-checks"
  project   = var.gcp_project
  network   = google_compute_network.trusted.name
  priority  = 1000
  direction = "INGRESS"

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
resource "google_compute_router" "this" {
  name    = "trace-test-cloud-router"
  region  = var.gcp_region
  project = var.gcp_project
  network = google_compute_network.untrusted.name
}

resource "google_compute_router_nat" "this" {
  name                               = "${google_compute_router.this.name}-nat"
  router                             = google_compute_router.this.name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
resource "google_compute_address" "lan" {
  name         = "fw-lan-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.trusted.self_link
  address      = cidrhost(google_compute_subnetwork.trusted.ip_cidr_range, 2)
}

resource "google_compute_address" "wan" {
  name         = "fw-wan-internal-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.untrusted.self_link
  address      = cidrhost(google_compute_subnetwork.untrusted.ip_cidr_range, 2)
}

resource "google_compute_address" "external_lb" {
  name         = "external-lb-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  region       = var.gcp_region
}

resource "google_compute_address" "internal_lb" {
  name         = "internal-lb-ip"
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.trusted.self_link
  purpose      = "GCE_ENDPOINT"
  region       = var.gcp_region
  address      = cidrhost(google_compute_subnetwork.trusted.ip_cidr_range, 255)

}
