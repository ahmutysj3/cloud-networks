// This resource represents a firewall rule for untrusted networks
resource "google_compute_firewall" "untrusted" {
  name      = "default-allow-all-untrusted"         // Name of the firewall rule
  project   = var.gcp_project                       // GCP project ID
  network   = google_compute_network.untrusted.name // Network name
  priority  = 1000                                  // Priority of the rule
  direction = "INGRESS"                             // Direction of traffic

  source_ranges = ["0.0.0.0/0"] // Source IP ranges

  // Log configuration
  log_config {
    metadata = "INCLUDE_ALL_METADATA" // Include all metadata in logs
  }

  // Allow all protocols
  allow {
    protocol = "all"
  }

  target_tags = ["firewall"] // Target tags
}

// This resource represents a firewall rule for trusted networks
resource "google_compute_firewall" "trusted" {
  name      = "default-allow-all-trusted"         // Name of the firewall rule
  project   = var.gcp_project                     // GCP project ID
  network   = google_compute_network.trusted.name // Network name
  priority  = 1000                                // Priority of the rule
  direction = "INGRESS"                           // Direction of traffic

  source_ranges = ["0.0.0.0/0"] // Source IP ranges

  // Log configuration
  log_config {
    metadata = "INCLUDE_ALL_METADATA" // Include all metadata in logs
  }

  // Allow all protocols
  allow {
    protocol = "all"
  }

  target_tags = ["firewall"] // Target tags
}

// This resource represents a firewall rule for protected networks
resource "google_compute_firewall" "protected" {
  name      = "allow-all-from-trusted-to-protected" // Name of the firewall rule
  project   = var.gcp_project                       // GCP project ID
  network   = google_compute_network.protected.name // Network name
  priority  = 1000                                  // Priority of the rule
  direction = "INGRESS"                             // Direction of traffic

  source_ranges = [google_compute_subnetwork.trusted.ip_cidr_range] // Source IP ranges

  // Log configuration
  log_config {
    metadata = "INCLUDE_ALL_METADATA" // Include all metadata in logs
  }

  // Allow all protocols
  allow {
    protocol = "all"
  }
}

// This resource represents a firewall rule for mgmt networks
resource "google_compute_firewall" "mgmt" {
  name      = "allow-all-from-trusted-to-mgmt" // Name of the firewall rule
  project   = var.gcp_project                  // GCP project ID
  network   = google_compute_network.mgmt.name // Network name
  priority  = 1000                             // Priority of the rule
  direction = "INGRESS"                        // Direction of traffic

  source_ranges = ["0.0.0.0/0"] // Source IP ranges

  // Log configuration
  log_config {
    metadata = "INCLUDE_ALL_METADATA" // Include all metadata in logs
  }

  // Allow all protocols
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

}
