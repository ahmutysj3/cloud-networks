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