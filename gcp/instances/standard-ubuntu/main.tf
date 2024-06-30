locals {
  vm_definitions_decoded = yamldecode(file("${path.module}/instances.yaml"))
  vm_definitions         = { for k, v in local.vm_definitions_decoded["instances"] : v.name => v }
}

data "google_compute_image" "this" {
  for_each = { for k, v in local.vm_definitions : v.name => v }
  project  = each.value.image["project"]
  name     = each.value.image["name"]
}

data "google_compute_subnetwork" "this" {
  for_each = { for k, v in local.vm_definitions : v.name => v }
  project  = each.value.nic["vpc_project"]
  region   = var.gcp_region
  name     = each.value.nic["subnet"]
}

data "google_compute_zones" "available" {
  region = var.gcp_region
}

data "google_compute_default_service_account" "this" {}

resource "google_compute_address" "external" {
  for_each     = { for k, v in local.vm_definitions : v.name => v if v.nic["assign_public_ip"] == true }
  name         = "${each.value.name}-external-ip"
  project      = each.value.nic["vpc_project"]
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}

resource "google_compute_address" "internal" {
  for_each     = { for k, v in local.vm_definitions : v.name => v }
  name         = "${each.value.name}-internal-ip"
  project      = each.value.vm_project
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.this[each.key].self_link
  address      = each.value.nic["address"]
}

resource "google_compute_instance" "this" {
  for_each     = { for k, v in local.vm_definitions : v.name => v }
  name         = each.value.name
  machine_type = coalesce(each.value.machine_type, "e2-micro")
  zone         = coalesce(each.value.zone, data.google_compute_zones.available.names[0])
  project      = each.value.vm_project
  tags         = each.value.tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.this[each.key].id
    }
  }

  network_interface {
    stack_type = "IPV4_ONLY"
    subnetwork = data.google_compute_subnetwork.this[each.key].self_link
    network_ip = google_compute_address.internal[each.key].address

    dynamic "access_config" {
      for_each = each.value.nic["assign_public_ip"] == true ? [1] : []

      content {
        nat_ip = google_compute_address.external[each.key].address
      }
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  service_account {
    email  = data.google_compute_default_service_account.this.email
    scopes = ["cloud-platform"]
  }
}
