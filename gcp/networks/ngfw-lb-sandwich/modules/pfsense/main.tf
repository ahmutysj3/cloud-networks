resource "google_compute_instance_from_machine_image" "pfsense" {
  depends_on           = [module.network]
  provider             = google-beta
  zone                 = data.google_compute_zones.available.names[0]
  name                 = var.pfsense_name
  source_machine_image = var.pfsense_machine_image

  network_interface {
    network_ip = var.wan_nic_ip
    subnetwork = module.network.subnets["untrusted-subnet"].self_link

    /* access_config = {
      nat_ip = google_compute_address.fw_external
    } */
  }
  network_interface {
    network_ip = var.lan_nic_ip
    subnetwork = module.network.subnets["trusted-subnet"].self_link
  }
}

resource "google_compute_address" "fw_external" {
  name         = "pfsense-wan-address"
  address_type = "EXTERNAL"
  region       = var.gcp_region
  project      = var.gcp_project
}


variable "wan_subnet" {
  type    = string
  default = module.network.subnets["untrusted-subnet"].self_link
}

variable "lan_subnet" {
  type    = string
  default = module.network.subnets["trusted-subnet"].self_link
}
