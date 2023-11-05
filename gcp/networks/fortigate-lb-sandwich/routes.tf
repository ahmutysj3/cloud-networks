
resource "google_compute_route" "untrusted_inet" {
  project          = var.gcp_project
  network          = google_compute_network.untrusted.name
  name             = "untrusted-inet-route"
  dest_range       = "0.0.0.0/0"
  priority         = 1000
  next_hop_gateway = "default-internet-gateway"
}
