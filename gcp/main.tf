resource "google_compute_network" "hub" {
  project                 = var.gcp_project
  #auto_create_subnetworks = false
  name                    = "hub-vpc"
}

resource "google_compute_network" "spoke1" {
  project                 = var.gcp_project
  #auto_create_subnetworks = false
  name                    = "spoke1-vpc"
}

resource "google_compute_network" "spoke2" {
  project                 = var.gcp_project
  #auto_create_subnetworks = false
  name                    = "spoke2-vpc"
}

resource "google_compute_network" "spoke3" {
  project                 = var.gcp_project
  #auto_create_subnetworks = false
  name                    = "spoke3-vpc"
}

resource "google_compute_subnetwork" "fw_inside" {
  name          = "fw_inside_subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.hub.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "fw_outside" {
  name          = "fw_outside_subnet"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.hub.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "spoke1" {
  name          = "spoke1_subnet"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.spoke1.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "spoke2" {
  name          = "spoke2_subnet"
  ip_cidr_range = "10.2.0.0/16"
  network       = google_compute_network.spoke2.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

}

resource "google_compute_subnetwork" "spoke3" {
  name          = "spoke3_subnet"
  ip_cidr_range = "10.3.0.0/16"
  network       = google_compute_network.spoke3.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}