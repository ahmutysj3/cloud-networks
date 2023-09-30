resource "google_compute_network" "app" {
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "app-vpc"
  delete_default_routes_on_create = true
}

resource "google_compute_network" "db" {
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "db-vpc"
  delete_default_routes_on_create = true
}

resource "google_compute_network" "dmz" {
  project                 = var.gcp_project
  auto_create_subnetworks = false
  name                    = "dmz-vpc"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "app" {
  name          = "app-subnet"
  ip_cidr_range = "10.1.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.app.self_link

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "db" {
  name          = "db-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.db.self_link

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

}

resource "google_compute_subnetwork" "dmz" {
  name          = "dmz-subnet"
  ip_cidr_range = "10.3.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.dmz.self_link

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}