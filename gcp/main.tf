resource "google_compute_network" "main" {
  for_each                = var.vpc_params
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "main-${each.key}-vpc"
}

resource "google_compute_subnetwork" "main" {
  for_each      = var.subnet_params
  project       = var.gcp_project
  region        = var.gcp_region
  name          = "main-${each.key}-subnet"
  ip_cidr_range = each.value.cidr
  network       = google_compute_network.main[each.value.vpc].id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling = 0.5
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_network_peering" "requestor" {
  for_each = {for network, attribute in google_compute_network.main : network => attribute.self_link if network != "hub"}
  name         = "${each.key}-to-hub-peering"
  network      = google_compute_network.main[each.key].self_link
  peer_network = lookup({for network, attribute in google_compute_network.main : network => attribute.self_link if network == "hub"},"hub",null)
}

resource "google_compute_network_peering" "acceptor" {
  for_each = {for network, attribute in google_compute_network.main : network => attribute.self_link if network != "hub"}
  name         = "hub-to-${each.key}-peering"
  network      = lookup({for network, attribute in google_compute_network.main : network => attribute.self_link if network == "hub"},"hub",null)
  peer_network = google_compute_network.main[each.key].self_link
}

resource "google_compute_router" "main" {
  project = var.gcp_project
  region  = var.gcp_region
  name    = "main-test-router"
  network = google_compute_network.main["hub"].name
  bgp {
    asn               = 16550
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# Comment out until you have a partner interconnect
/* resource "google_compute_interconnect_attachment" "main" {
  project       = var.gcp_project
  region        = var.gcp_region
  name          = "main-test-ic-attach"
  type          = "PARTNER"
  router        = google_compute_router.main.id
  mtu           = 1500
  admin_enabled = true
} */

