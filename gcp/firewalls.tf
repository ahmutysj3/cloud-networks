/* resource "google_compute_firewall" "hub_trusted" {
  name    = "test-firewall"
  network = google_compute_network.hub.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
} */

resource "google_compute_firewall" "allow_all" {
  name    = "test-firewall"
  network = google_compute_network.hub.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}