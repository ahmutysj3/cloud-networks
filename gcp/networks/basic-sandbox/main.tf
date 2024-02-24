resource "google_compute_network" "this" {
  project                 = var.project
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  project       = var.project
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.this.self_link
  ip_cidr_range = var.ip_cidr_range
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


