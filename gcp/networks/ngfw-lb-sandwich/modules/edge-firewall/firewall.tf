locals {
  firewall_name = "firewall"
}

data "google_client_config" "this" {

}

resource "google_compute_address" "this" {
  name         = "fw-external-ip"
  address_type = "EXTERNAL"
  project      = data.google_client_config.this.project
  ip_version   = "IPV4"
  region       = data.google_client_config.this.region

}

data "google_compute_subnetwork" "untrusted" {
  project   = data.google_client_config.this.project
  region    = data.google_client_config.this.region
  self_link = var.untrusted_subnet
}

data "google_compute_subnetwork" "trusted" {
  project   = data.google_client_config.this.project
  region    = data.google_client_config.this.region
  self_link = var.trusted_subnet
}


resource "google_compute_instance" "firewall" {
  name           = local.firewall_name
  machine_type   = "n1-standard-2"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = true
  project        = data.google_client_config.this.project
  metadata = {
    serial-port-enable = "TRUE"
    ssh-keys           = "trace:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjI2kHRd2kAMmb8wbVmu66q/MfHhGiop6tZ1s7e9iJ+TzOK0S92cfIxrBTu08J6MhTg/CUfZwHe6WKB3sA5A2tWOLLpYdkvvwAojOh0z7hD9l8UZ57agRu0aaVfOofQwhQBWZFiOWIOUWmLAtHCxejV24ICJt/+pk1D+0MhqulKccC1Si7RZgzBqGzeH64mwgTbbl/QD3Hf2NcT5PvUZL9yWJDonoh1CZ5j4SfU/YJBBQXXsI3LJkH5gGCz2+CY+ZhZbtnCLrDMsgzK9uUSamdZ7bIiBi0LAM8P9O+QK75kBwnyRvQly92sIP50uxMGAfI8D/MfmHoP9pcTmHFbWcv trace@trace-laptop"
  }

  tags = ["firewall"]

  boot_disk {
    auto_delete = true
    device_name = "boot-disk"
    mode        = "READ_WRITE"
    source      = google_compute_disk.firewall_boot.self_link
  }

  network_interface { # nic0: WAN Interface
    nic_type   = "VIRTIO_NET"
    subnetwork = var.untrusted_subnet
    network    = var.untrusted_network
    network_ip = cidrhost(data.google_compute_subnetwork.untrusted.ip_cidr_range, 2)

    access_config {
      nat_ip = google_compute_address.this.address
    }
  }

  network_interface { # nic1: LAN Interface
    nic_type   = "VIRTIO_NET"
    subnetwork = var.trusted_subnet
    network    = var.trusted_network
    network_ip = cidrhost(data.google_compute_subnetwork.trusted.ip_cidr_range, 2)
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

variable "trusted_subnet" {
  type = string
}

variable "untrusted_subnet" {
  type = string
}

variable "trusted_network" {
  type = string

}

variable "untrusted_network" {
  type = string
}

data "google_compute_zones" "available" {
  region = data.google_client_config.this.region
}

data "google_compute_default_service_account" "default" {
}

resource "google_compute_disk" "firewall_boot" {
  image                     = data.google_compute_image.pfsense.self_link
  name                      = "firewall-boot-disk"
  physical_block_size_bytes = 4096
  project                   = data.google_client_config.this.project
  size                      = 50
  type                      = "pd-standard"
  zone                      = data.google_compute_zones.available.names[0]
}

data "google_compute_image" "pfsense" {
  project = data.google_client_config.this.project
  name    = "pfsense-fully-configured"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=5.9"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">=3.79.0"
    }
  }
}
