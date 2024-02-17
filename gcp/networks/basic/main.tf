resource "google_compute_network" "this" {
  project                 = var.project
  name                    = "test-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  project       = var.project
  name          = "test-subnet"
  region        = var.region
  network       = google_compute_network.this.self_link
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_firewall" "this" {
  project     = var.project
  name        = "allow-all"
  target_tags = ["allow-all"]
  network     = google_compute_network.this.self_link
  allow {
    protocol = "all"
  }
  source_ranges      = ["0.0.0.0/0"]
  destination_ranges = ["0.0.0.0/0"]
}
