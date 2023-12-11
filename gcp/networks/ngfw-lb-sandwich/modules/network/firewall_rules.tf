// This resource represents a firewall rule for untrusted networks


resource "google_compute_firewall" "ingress" {
  for_each      = local.vpcs
  name          = "default-allow-all-ingress-${each.key}"
  project       = var.gcp_project
  network       = google_compute_network.this[each.key].name
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "egress" {
  for_each           = local.vpcs
  name               = "default-allow-all-egress-${each.key}"
  project            = var.gcp_project
  network            = google_compute_network.this[each.key].name
  priority           = 1000
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

