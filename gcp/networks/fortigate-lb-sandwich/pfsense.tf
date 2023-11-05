resource "google_compute_instance" "pfsense" {
  name           = "pfsense-active1-fw"
  machine_type   = "e2-standard-4"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = true
  project        = var.gcp_project
  metadata = {
    enable-oslogin           = true
    google-logging-enable    = "0"
    google-monitoring-enable = "0"
    ssh-keys                 = "trace:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjI2kHRd2kAMmb8wbVmu66q/MfHhGiop6tZ1s7e9iJ+TzOK0S92cfIxrBTu08J6MhTg/CUfZwHe6WKB3sA5A2tWOLLpYdkvvwAojOh0z7hD9l8UZ57agRu0aaVfOofQwhQBWZFiOWIOUWmLAtHCxejV24ICJt/+pk1D+0MhqulKccC1Si7RZgzBqGzeH64mwgTbbl/QD3Hf2NcT5PvUZL9yWJDonoh1CZ5j4SfU/YJBBQXXsI3LJkH5gGCz2+CY+ZhZbtnCLrDMsgzK9uUSamdZ7bIiBi0LAM8P9O+QK75kBwnyRvQly92sIP50uxMGAfI8D/MfmHoP9pcTmHFbWcv trace@trace-laptop"
  }

  boot_disk {
    auto_delete = true
    device_name = "boot-disk"
    mode        = "READ_WRITE"
    source      = google_compute_disk.pfsense_boot.self_link
  }


  network_interface { # nic0: WAN Interface
    nic_type           = "VIRTIO_NET"
    network            = google_compute_network.untrusted.name
    network_ip         = google_compute_address.wan.address
    stack_type         = "IPV4_ONLY"
    subnetwork         = google_compute_subnetwork.untrusted.self_link
    subnetwork_project = var.gcp_project
  }

  network_interface { # nic1: LAN Interface
    nic_type           = "VIRTIO_NET"
    network            = google_compute_network.trusted.name
    network_ip         = google_compute_address.lan.address
    stack_type         = "IPV4_ONLY"
    subnetwork         = google_compute_subnetwork.trusted.self_link
    subnetwork_project = var.gcp_project
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

resource "google_compute_disk" "pfsense_boot" {
  image                     = data.google_compute_image.pfsense.self_link
  name                      = "pfsense-boot-disk"
  physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = var.boot_disk_size
  type                      = "pd-standard"
  zone                      = data.google_compute_zones.available.names[0]
}

data "google_compute_image" "pfsense" {
  project     = var.gcp_project
  most_recent = true
  name        = "pfsense-gcp-image"
}

