locals {
  firewall_name = "${var.model}-firewall"

  fw_gateways = {
    untrusted = var.fw_network_interfaces[0].gateway
    trusted   = var.fw_network_interfaces[1].gateway
  }

  firewall_images = {
    pfsense   = data.google_compute_image.pfsense.self_link
    fortigate = data.google_compute_image.fortigate.self_link
  }
}

data "google_client_config" "this" {
}

data "google_compute_zones" "available" {
  region = data.google_client_config.this.region
}

data "google_compute_default_service_account" "default" {
}

data "google_compute_image" "pfsense" {
  project = data.google_client_config.this.project
  name    = "pfsense-272-fully-configured"
}

data "google_compute_image" "fortigate" {
  family  = "fortigate-74-payg"
  project = "fortigcp-project-001"
}


resource "google_compute_address" "mgmt" {
  name         = "fw-mgmt-external-ip"
  address_type = "EXTERNAL"
  project      = data.google_client_config.this.project
  ip_version   = "IPV4"
  region       = data.google_client_config.this.region
}


# Firewall instance and instance group
resource "google_compute_instance_group" "this" {
  provider  = google
  name      = "firewall-elb-instance-group"
  zone      = google_compute_instance.this.zone
  instances = [google_compute_instance.this.id]
}

resource "google_compute_instance" "this" {
  name           = local.firewall_name
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
    device_name = "boot-disk"
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
          nat_ip = google_compute_address.mgmt.address
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
  image                     = local.firewall_images[var.model]
  name                      = "firewall-boot-disk"
  physical_block_size_bytes = 4096
  project                   = data.google_client_config.this.project
  size                      = 50
  type                      = "pd-standard"
  zone                      = data.google_compute_zones.available.names[0]
}

module "load_balancers" {
  source                   = "./load-balancers"
  for_each                 = toset(var.lb_types)
  lb_type                  = each.key
  hc_port                  = var.fw_gui_port
  instance_group_self_link = google_compute_instance_group.this.self_link
  trusted_subnet           = data.google_compute_subnetwork.trusted.self_link
  trusted_network          = var.fw_network_interfaces[1].vpc
}

variable "lb_types" {
  type    = list(string)
  default = ["ilb", "elb"]
}

variable "fw_gui_port" {
  type    = number
  default = 8001
}

data "google_compute_network" "trusted" {
  project = data.google_client_config.this.project
  name    = var.fw_network_interfaces[1].vpc
}

data "google_compute_subnetwork" "trusted" {
  project   = data.google_client_config.this.project
  self_link = var.fw_network_interfaces[1].subnet
}
