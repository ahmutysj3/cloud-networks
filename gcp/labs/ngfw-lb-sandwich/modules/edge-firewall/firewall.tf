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

  image_projects = {
    pfsense   = data.google_client_config.this.project
    fortigate = "fortigcp-project-001"
    palo-alto = "paloaltonetworksgcp-public"
  }

  image_name = {
    pfsense   = "pfsense-272-fully-configured-new"
    fortigate = null
    palo-alto = "vmseries-flex-bundle2-1018h2"
  }

  image_family = {
    pfsense   = null
    fortigate = "fortigate-74-payg"
    palo-alto = null
  }


  firewall_image = {
    project = local.image_projects[var.model]
    name    = local.image_name[var.model]
    family  = local.image_family[var.model]
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
  source   = "./load-balancers"
  for_each = toset(var.lb_types)
  lb_type  = each.key
  hc_port  = var.gui_port
  instance_groups = {
    active  = google_compute_instance_group.this[0].self_link
    standby = google_compute_instance_group.this[1].self_link
  }
  trusted_subnet  = var.fw_network_interfaces[1].subnet
  trusted_network = var.fw_network_interfaces[1].vpc
}

resource "google_compute_address" "this" {
  count = 2
  name  = "${local.names["address"]}-${count.index}"

  address_type = var.address_params.address_type
  project      = data.google_client_config.this.project
  ip_version   = var.address_params.ip_version
  region       = data.google_client_config.this.region
}

# Firewall instance and instance group
resource "google_compute_instance_group" "this" {
  count = 2

  project   = data.google_client_config.this.project
  provider  = google
  name      = "${local.names["instance_group"]}-${count.index}"
  zone      = google_compute_instance.this[count.index].zone
  instances = [google_compute_instance.this[count.index].id]
}

resource "google_compute_instance" "this" {
  count          = 2
  name           = "${local.names["instance"]}-${count.index}"
  machine_type   = "n2-standard-4"
  zone           = data.google_compute_zones.available.names[count.index]
  can_ip_forward = true
  project        = data.google_client_config.this.project
  metadata = {
    serial-port-enable  = true
    mgmt-interface-swap = "enable"
    ssh-keys            = var.ssh_public_key
  }

  tags = ["firewall"]

  boot_disk {
    auto_delete = true
    device_name = local.names["disk"]
    mode        = "READ_WRITE"
    source      = google_compute_disk.firewall_boot[count.index].self_link
  }

  dynamic "network_interface" {
    for_each = var.fw_network_interfaces
    content {
      nic_type   = "VIRTIO_NET"
      network    = network_interface.value.vpc
      subnetwork = network_interface.value.subnet
      network_ip = network_interface.value.ip_addr

      dynamic "access_config" {
        for_each = network_interface.value.vpc == var.fw_public_interface ? [1] : []
        content {
          nat_ip = google_compute_address.this[count.index].address
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
  count                     = 2
  image                     = data.google_compute_image.this.self_link
  name                      = "${local.names["disk"]}-${count.index}"
  physical_block_size_bytes = 4096
  project                   = data.google_client_config.this.project
  size                      = 100
  type                      = "pd-standard"
  zone                      = data.google_compute_zones.available.names[0]
}
