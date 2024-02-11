locals {
  fw_gateways = {
    untrusted = var.fw_network_interfaces[0].gateway
    trusted   = var.fw_network_interfaces[1].gateway
  }

  names = {
    instance_group = "firewall-instance-group"
    instance       = "${var.model}-firewall-instance"
    disk           = "firewall-boot-disk"
    address        = "firewall-mgmt-external-ip"
  }

  firewall_image = {
    project = var.model == "pfsense" ? data.google_client_config.this.project : "fortigcp-project-001"
    name    = var.model == "pfsense" ? "pfsense-272-fully-configured-new" : null
    family  = var.model == "fortigate" ? "fortigate-74-payg" : null
  }
}

data "google_client_config" "this" {
}

data "google_compute_zones" "available" {
  region = data.google_client_config.this.region
}

data "google_compute_default_service_account" "default" {
}

data "google_compute_image" "this" {
  project = local.firewall_image.project
  name    = local.firewall_image.name
  family  = local.firewall_image.family
}

module "load_balancers" {
  source                   = "./load-balancers"
  for_each                 = toset(var.lb_types)
  lb_type                  = each.key
  hc_port                  = var.gui_port
  instance_group_self_link = google_compute_instance_group.this.self_link
  trusted_subnet           = var.fw_network_interfaces[1].subnet
  trusted_network          = var.fw_network_interfaces[1].vpc
}

resource "google_compute_address" "this" {
  name         = local.names["address"]
  address_type = "EXTERNAL"
  project      = data.google_client_config.this.project
  ip_version   = "IPV4"
  region       = data.google_client_config.this.region
}

# Firewall instance and instance group
resource "google_compute_instance_group" "this" {
  project   = data.google_client_config.this.project
  provider  = google
  name      = local.names["instance_group"]
  zone      = google_compute_instance.this.zone
  instances = [google_compute_instance.this.id]
}

resource "google_compute_instance" "this" {
  name           = local.names["instance"]
  machine_type   = "n1-standard-2"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = true
  project        = data.google_client_config.this.project
  metadata = {
    serial-port-enable = "TRUE"
    ssh-keys           = var.ssh_public_key
  }

  tags = ["firewall"]

  boot_disk {
    auto_delete = true
    device_name = local.names["disk"]
    mode        = "READ_WRITE"
    source      = google_compute_disk.firewall_boot.self_link
  }

  dynamic "network_interface" {
    for_each = var.fw_network_interfaces
    content {
      nic_type   = "VIRTIO_NET"
      network    = network_interface.value.vpc
      subnetwork = network_interface.value.subnet
      network_ip = network_interface.value.ip_addr

      dynamic "access_config" {
        for_each = network_interface.value.vpc == "untrusted-vpc" ? [1] : []
        content {
          nat_ip = google_compute_address.this.address
        }
      }
    }
  }

  scheduling { # Discounted Rates
    automatic_restart           = false
    preemptible                 = true
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP"
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

}

resource "google_compute_disk" "firewall_boot" {
  image                     = data.google_compute_image.this.self_link
  name                      = local.names["disk"]
  physical_block_size_bytes = 4096
  project                   = data.google_client_config.this.project
  size                      = 50
  type                      = "pd-standard"
  zone                      = data.google_compute_zones.available.names[0]
}
