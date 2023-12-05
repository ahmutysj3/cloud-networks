locals {
  firewall_name = "fortigate-active1-fw"
}



resource "google_compute_instance" "firewall" {
  name           = local.firewall_name
  machine_type   = "e2-standard-4"
  zone           = var.zones[0]
  can_ip_forward = true
  project        = var.gcp_project
  metadata = {
    user-data = templatefile("${path.module}/bootstrap3.tpl", {
      hostname         = local.firewall_name
      port1_ip         = google_compute_address.wan.address
      port2_ip         = google_compute_address.lan.address
      port1_gateway    = var.subnets.untrusted.gateway
      port2_gateway    = var.subnets.trusted.gateway
      trusted_subnet   = var.subnets.trusted.cidr
      untrusted_subnet = var.subnets.untrusted.cidr
      elb_ip           = google_compute_address.lb_external.address
      ilb_ip           = google_compute_address.lb_internal.address
    })
    ssh-keys = "trace:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjI2kHRd2kAMmb8wbVmu66q/MfHhGiop6tZ1s7e9iJ+TzOK0S92cfIxrBTu08J6MhTg/CUfZwHe6WKB3sA5A2tWOLLpYdkvvwAojOh0z7hD9l8UZ57agRu0aaVfOofQwhQBWZFiOWIOUWmLAtHCxejV24ICJt/+pk1D+0MhqulKccC1Si7RZgzBqGzeH64mwgTbbl/QD3Hf2NcT5PvUZL9yWJDonoh1CZ5j4SfU/YJBBQXXsI3LJkH5gGCz2+CY+ZhZbtnCLrDMsgzK9uUSamdZ7bIiBi0LAM8P9O+QK75kBwnyRvQly92sIP50uxMGAfI8D/MfmHoP9pcTmHFbWcv trace@trace-laptop"
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
    network_ip = google_compute_address.wan.address
    subnetwork = var.subnets.untrusted.self_link


    access_config {
      nat_ip       = google_compute_address.wan_external.address
      network_tier = "PREMIUM"
    }
  }

  network_interface { # nic1: LAN Interface
    nic_type   = "VIRTIO_NET"
    network_ip = google_compute_address.lan.address
    subnetwork = var.subnets.trusted.self_link
  }

  scheduling { # Discounted Rates
    automatic_restart           = false
    preemptible                 = true
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP"
  }

  service_account {
    email  = var.default_service_account
    scopes = ["cloud-platform"]
  }

}

resource "google_compute_disk" "firewall_boot" {
  image                     = var.image
  name                      = "firewall-boot-disk"
  physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = var.boot_disk_size
  type                      = "pd-standard"
  zone                      = var.zones[0]
}





/* resource "google_compute_instance_group" "firewall" {
  name      = "firewall-instancegroup"
  zone      = var.zones[0]
  network   = var.vpcs.untrusted.self_link
  project   = var.gcp_project
  instances = [google_compute_instance.firewall.self_link]
} */

