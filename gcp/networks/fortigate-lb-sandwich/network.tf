resource "google_compute_network" "trusted" {
  project                                   = var.gcp_project
  name                                      = "test-trusted-vpc-network"
  auto_create_subnetworks                   = false
  delete_default_routes_on_create           = true
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
  enable_ula_internal_ipv6                  = false
  routing_mode                              = "REGIONAL"
}

resource "google_compute_network" "untrusted" {
  project                                   = var.gcp_project
  name                                      = "test-untrusted-vpc-network"
  auto_create_subnetworks                   = false
  delete_default_routes_on_create           = true
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
  enable_ula_internal_ipv6                  = false
  routing_mode                              = "REGIONAL"
}

resource "google_compute_network" "protected" {
  project                                   = var.gcp_project
  name                                      = "test-protected-vpc-network"
  auto_create_subnetworks                   = false
  delete_default_routes_on_create           = true
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
  enable_ula_internal_ipv6                  = false
  routing_mode                              = "REGIONAL"
}

resource "google_compute_network_peering" "trusted" {
  name         = "trusted-to-protected-peering"
  network      = google_compute_network.trusted.self_link
  peer_network = google_compute_network.protected.self_link
}

resource "google_compute_network_peering" "protected" {
  name         = "protected-to-trusted-peering"
  network      = google_compute_network.protected.self_link
  peer_network = google_compute_network.trusted.self_link
}

resource "google_compute_subnetwork" "trusted" {
  project       = var.gcp_project
  name          = "test-trusted-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.trusted.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

resource "google_compute_subnetwork" "untrusted" {
  project       = var.gcp_project
  name          = "test-untrusted-subnet"
  ip_cidr_range = "10.255.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.untrusted.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

resource "google_compute_subnetwork" "protected" {
  project       = var.gcp_project
  name          = "test-protected-subnet"
  ip_cidr_range = "192.168.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.protected.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}
