
resource "google_compute_route" "untrusted_inet" {
  project          = var.gcp_project
  network          = google_compute_network.untrusted.name
  name             = "untrusted-inet-route"
  dest_range       = "0.0.0.0/0"
  priority         = 1000
  next_hop_gateway = "default-internet-gateway"
}


resource "google_compute_route" "default_route" {
  name         = "default-route-via-fw"
  network      = google_compute_network.trusted.self_link
  dest_range   = "0.0.0.0/0"
  priority     = 100
  next_hop_ilb = google_compute_forwarding_rule.ilb.ip_address
}
