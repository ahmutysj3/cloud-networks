resource "google_compute_network" "hub" {
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "hub-vpc"
  delete_default_routes_on_create = true
}

resource "google_compute_route" "hub_inet" {
  name        = "default-route"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.hub.self_link
  next_hop_gateway = "default-internet-gateway"
  priority    = 0
}

resource "google_compute_subnetwork" "fw_inside" {
  name          = "fw-inside-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.hub.self_link

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "fw_outside" {
  name          = "fw-outside-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.gcp_region
  network       = google_compute_network.hub.self_link
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}