locals {
  outputs = {
    interfaces     = var.interfaces
    compute_params = var.compute_params
    disk_params    = var.disk_params
  }
}


data "google_compute_image" "palo_vmseries" {
  name    = var.compute_params.image_name
  project = "paloaltonetworksgcp-public"
}

output "interfaces" {
  value = local.outputs.interfaces
}

output "compute_params" {
  value = local.outputs.compute_params
}

output "disk_params" {
  value = local.outputs.disk_params
}

data "google_compute_subnetwork" "this" {
  for_each = var.interfaces
  project  = each.value.subnet_project
  region   = var.region
  name     = each.value.subnet
}

data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

output "fw_subnets" {
  value = data.google_compute_subnetwork.this
}

resource "google_compute_address" "this" {
  count        = 2
  name         = "${var.name}-nat-ip-${count.index}"
  project      = var.project_id
  purpose      = "GCE_ENDPOINT"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "this" {
  count                     = 2
  name                      = "${var.name}-${count.index}"
  zone                      = data.google_compute_zones.available.names[count.index]
  machine_type              = var.compute_params.machine_type
  project                   = var.project_id
  can_ip_forward            = true
  allow_stopping_for_update = true

  metadata = {
    serial-port-enable  = true
    mgmt-interface-swap = "enable"
  }

  dynamic "network_interface" {
    for_each = var.interfaces

    content {
      network_ip = cidrhost(data.google_compute_subnetwork.this[network_interface.key].ip_cidr_range, 2 + count.index)
      subnetwork = data.google_compute_subnetwork.this[network_interface.key].self_link

/*       dynamic "access_config" {
        for_each = network_interface.value.public_ip ? [1] : []
        content {
          nat_ip                 = local.access_configs[network_interface.key].nat_ip
          public_ptr_domain_name = local.access_configs[network_interface.key].public_ptr_domain_name
        }
      } */
    }
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.palo_vmseries.self_link
      type  = var.disk_params.disk_type
      size = var.disk_params.disk_size
    }
  }

}