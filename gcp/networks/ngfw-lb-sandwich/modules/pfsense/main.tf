resource "google_compute_instance_from_machine_image" "pfsense" {
  provider             = google-beta
  zone                 = data.google_compute_zones.available.names[0]
  name                 = var.pfsense_name
  source_machine_image = var.pfsense_machine_image

  network_interface {
    network_ip = var.wan_nic_ip
    subnetwork = var.wan_subnet

    /* access_config = {
      nat_ip = google_compute_address.fw_external
    } */
  }
  network_interface {
    network_ip = var.lan_nic_ip
    subnetwork = var.lan_subnet
  }
}

resource "google_compute_address" "fw_external" {
  name         = "pfsense-wan-address"
  address_type = "EXTERNAL"
  region       = var.gcp_region
  project      = var.gcp_project
}

data "google_compute_zones" "available" {
  region = var.gcp_region
}
