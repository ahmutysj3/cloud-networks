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

  target_tags = ["firewall"]
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

  target_tags = ["firewall"]
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
    ports    = ["8008"]
  }

  target_tags = ["firewall"]

}
