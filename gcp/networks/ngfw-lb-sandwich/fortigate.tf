locals {
  config_active = templatefile("./fgt-base-config.tpl", {
    hostname         = local.fortigate_name
    healthcheck_port = google_compute_region_health_check.firewall.tcp_health_check[0].port
    ext_ip           = google_compute_address.wan.address
    ext_gw           = google_compute_subnetwork.untrusted.gateway_address
    int_ip           = google_compute_address.lan.address
    int_gw           = google_compute_subnetwork.protected.gateway_address
    int_cidr         = google_compute_subnetwork.protected.ip_cidr_range
    mgmt_ip          = google_compute_address.mgmt.address
    mgmt_gw          = google_compute_subnetwork.mgmt.gateway_address
    ilb_ip           = google_compute_address.internal_lb.address
  })
  fortigate_name = "fortigate-active1-fw"
}

resource "google_compute_instance" "fortigate" {
  name           = local.fortigate_name
  machine_type   = "e2-standard-4"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = true
  project        = var.gcp_project
  metadata = {
    #user-data = local.config_active
    ssh-keys = "trace:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjI2kHRd2kAMmb8wbVmu66q/MfHhGiop6tZ1s7e9iJ+TzOK0S92cfIxrBTu08J6MhTg/CUfZwHe6WKB3sA5A2tWOLLpYdkvvwAojOh0z7hD9l8UZ57agRu0aaVfOofQwhQBWZFiOWIOUWmLAtHCxejV24ICJt/+pk1D+0MhqulKccC1Si7RZgzBqGzeH64mwgTbbl/QD3Hf2NcT5PvUZL9yWJDonoh1CZ5j4SfU/YJBBQXXsI3LJkH5gGCz2+CY+ZhZbtnCLrDMsgzK9uUSamdZ7bIiBi0LAM8P9O+QK75kBwnyRvQly92sIP50uxMGAfI8D/MfmHoP9pcTmHFbWcv trace@trace-laptop"
  }

  tags = ["firewall"]

  boot_disk {
    auto_delete = true
    device_name = "boot-disk"
    mode        = "READ_WRITE"
    source      = google_compute_disk.fortigate_boot.self_link
  }

  network_interface { # nic0: WAN Interface
    nic_type   = "VIRTIO_NET"
    network_ip = google_compute_address.wan.address
    subnetwork = google_compute_subnetwork.untrusted.self_link
  }

  network_interface { # nic1: LAN Interface
    nic_type   = "VIRTIO_NET"
    network_ip = google_compute_address.lan.address
    subnetwork = google_compute_subnetwork.trusted.self_link
  }

  network_interface { # nic2: MGMT Interface
    nic_type   = "VIRTIO_NET"
    network_ip = google_compute_address.mgmt.address
    subnetwork = google_compute_subnetwork.mgmt.self_link

    access_config {
      nat_ip = google_compute_address.fw_mgmt_external.address
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

resource "google_compute_disk" "fortigate_boot" {
  image                     = data.google_compute_image.fortigate.self_link
  name                      = "fortigate-boot-disk"
  physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = var.boot_disk_size
  type                      = "pd-standard"
  zone                      = data.google_compute_zones.available.names[0]
}

data "google_compute_image" "fortigate" {
  provider = google
  family   = "fortigate-74-payg"
  project  = "fortigcp-project-001"
}

resource "google_compute_instance_group" "fortigate" {
  depends_on = [google_compute_instance.fortigate]
  name       = "fortigate-instance-group"
  zone       = data.google_compute_zones.available.names[0]
  instances  = [google_compute_instance.fortigate.self_link]
}

