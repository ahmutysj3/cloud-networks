resource "google_compute_network" "hub" {
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "hub-vpc"
  delete_default_routes_on_create = true
}

resource "google_compute_route" "hub_inet" {
  name        = "default-route"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.hub.name
  next_hop_gateway = "default-internet-gateway"
  priority    = 0
}

resource "google_compute_network_peering" "hub_to_spoke1" {
  name         = "hub-to-spoke1"
  network      = google_compute_network.hub.self_link
  peer_network = google_compute_network.spoke1.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_network_peering" "hub_to_spoke2" {
  name         = "hub-to-spoke2"
  network      = google_compute_network.hub.self_link
  peer_network = google_compute_network.spoke2.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_network_peering" "hub_to_spoke3" {
  name         = "hub-to-spoke3"
  network      = google_compute_network.hub.self_link
  peer_network = google_compute_network.spoke3.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_network" "spoke1" {
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "spoke1-vpc"
  delete_default_routes_on_create = true
}

resource "google_compute_network_peering" "spoke1_to_hub" {
  name         = "spoke1-to-hub"
  network      = google_compute_network.spoke1.self_link
  peer_network = google_compute_network.hub.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}


resource "google_compute_network" "spoke2" {
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "spoke2-vpc"
  delete_default_routes_on_create = true
}

resource "google_compute_network_peering" "spoke2_to_hub" {
  name         = "spoke2-to-hub"
  network      = google_compute_network.spoke2.self_link
  peer_network = google_compute_network.hub.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_network" "spoke3" {
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "spoke3-vpc"
  delete_default_routes_on_create = true
}

resource "google_compute_network_peering" "spoke3_to_hub" {
  name         = "spoke3-to-hub"
  network      = google_compute_network.spoke3.self_link
  peer_network = google_compute_network.hub.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_subnetwork" "fw_inside" {
  name          = "fw-inside-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.hub.id

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
  network       = google_compute_network.hub.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "spoke1" {
  name          = "spoke1-subnet"
  ip_cidr_range = "10.1.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.spoke1.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "spoke2" {
  name          = "spoke2-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.spoke2.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

}

resource "google_compute_subnetwork" "spoke3" {
  name          = "spoke3-subnet"
  ip_cidr_range = "10.3.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.spoke3.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}