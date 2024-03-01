data "google_compute_zones" "available" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_address" "mgmt" {
  name         = "${var.name}-nat-ip-${var.index}"
  project      = var.project_id
  address_type = "EXTERNAL"
}

data "google_compute_image" "palo_vmseries" {
  name    = var.image
  project = "paloaltonetworksgcp-public"
}

resource "google_compute_address" "internal" {
  for_each     = var.fw_vnics
  name         = "${var.name}-${each.value.interface}-fw0${var.index}-ip"
  project      = var.project_id
  address_type = "INTERNAL"
  subnetwork   = var.fw_subnets[each.key].self_link
}

resource "google_compute_instance" "this" {
  name                      = "${var.name}-${var.index}"
  zone                      = data.google_compute_zones.available.names[var.index]
  machine_type              = var.machine_type
  project                   = var.project_id
  can_ip_forward            = true
  allow_stopping_for_update = true

  metadata = {
    serial-port-enable  = true
    mgmt-interface-swap = "enable"
    ssh-keys            = var.ssh_key
  }

  dynamic "network_interface" {
    for_each = var.fw_vnics

    content {
      network_ip = google_compute_address.internal[network_interface.key].address
      subnetwork = google_compute_address.internal[network_interface.key].subnetwork

      dynamic "access_config" {
        for_each = network_interface.value.public_ip ? [1] : []
        content {
          nat_ip = google_compute_address.mgmt.address
        }
      }
    }
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.palo_vmseries.self_link
      type  = var.disk_params.disk_type
      size  = var.disk_params.disk_size
    }
  }
}

resource "google_compute_instance_group" "this" {
  name      = "${google_compute_instance.this.name}-ig"
  zone      = google_compute_instance.this.zone
  project   = var.project_id
  instances = [google_compute_instance.this.self_link]
}

output "instance_group" {
  value = google_compute_instance_group.this.self_link
}