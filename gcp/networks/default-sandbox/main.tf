resource "google_compute_network" "trusted" {
  project                         = var.gcp_project
  name                            = "trusted-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_network" "untrusted" {
  project                         = var.gcp_project
  name                            = "untrusted-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_network" "mgmt" {
  project                         = var.gcp_project
  name                            = "mgmt-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_network" "ha_sync" {
  project                         = var.gcp_project
  name                            = "fw-ha-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_network" "protected" {
  project                         = var.gcp_project
  name                            = "protected-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_network_peering" "hub" {
  name                 = "hub-peering"
  network              = google_compute_network.trusted.self_link
  peer_network         = google_compute_network.protected.self_link
  export_custom_routes = true
}

resource "google_compute_network_peering" "protected" {
  name                 = "protected-peering"
  network              = google_compute_network.protected.self_link
  peer_network         = google_compute_network.trusted.self_link
  import_custom_routes = true
}

resource "google_compute_subnetwork" "fw_trusted" {
  name          = "fw-trusted-subnet"
  ip_cidr_range = "10.99.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.trusted.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "fw_untrusted" {
  name          = "fw-untrusted-subnet"
  ip_cidr_range = "10.99.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.untrusted.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "fw_mgmt" {
  name          = "fw-mgmt-subnet"
  ip_cidr_range = "10.99.254.0/25"
  region        = var.gcp_region
  network       = google_compute_network.mgmt.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "fw_ha_sync" {
  name          = "fw-ha-subnet"
  ip_cidr_range = "10.99.255.0/24"
  region        = var.gcp_region
  network       = google_compute_network.ha_sync.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "protected" {
  name          = "protected-subnet"
  ip_cidr_range = "10.100.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.protected.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "admin" {
  name          = "admin-subnet"
  ip_cidr_range = "10.99.254.128/25"
  region        = var.gcp_region
  network       = google_compute_network.mgmt.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_route" "inet_access_mgmt" {
  name             = "inet-route-mgmt"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.mgmt.name
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}

resource "google_compute_route" "inet_access_wan" {
  name             = "inet-route-wan"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.untrusted.name
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}

/* resource "google_compute_route" "inet_access_trusted" {
  name        = "inet-route-trusted"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.trusted.name
  next_hop_ip = google_compute_instance.fortigate_active.network_interface[3].network_ip
  priority    = 100

  depends_on = [
    google_compute_network_peering.hub,
    google_compute_network_peering.protected
  ]
} */