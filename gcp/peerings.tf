resource "google_compute_network_peering" "hub_to_app" {
  name         = "hub-to-app"
  network      = google_compute_network.hub.self_link
  peer_network = google_compute_network.app.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_network_peering" "hub_to_db" {
  name         = "hub-to-db"
  network      = google_compute_network.hub.self_link
  peer_network = google_compute_network.db.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_network_peering" "hub_to_dmz" {
  name         = "hub-to-dmz"
  network      = google_compute_network.hub.self_link
  peer_network = google_compute_network.dmz.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_network_peering" "app_to_hub" {
  name         = "app-to-hub"
  network      = google_compute_network.app.self_link
  peer_network = google_compute_network.hub.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}
resource "google_compute_network_peering" "db_to_hub" {
  name         = "db-to-hub"
  network      = google_compute_network.db.self_link
  peer_network = google_compute_network.hub.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_network_peering" "dmz_to_hub" {
  name         = "dmz-to-hub"
  network      = google_compute_network.dmz.self_link
  peer_network = google_compute_network.hub.self_link
  stack_type   = "IPV4_ONLY"
  export_custom_routes = false
  import_custom_routes = false
  export_subnet_routes_with_public_ip = false
}