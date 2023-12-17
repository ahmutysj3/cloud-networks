locals {
  firewall_name = "fortigate-active1-fw"
}

resource "google_compute_route" "default" {
  name         = "default-route-to-fw"
  project      = var.gcp_project
  network      = var.vpcs["trusted"].name
  dest_range   = "0.0.0.0/0"
  next_hop_ilb = google_compute_forwarding_rule.ilb.ip_address
}

data "google_compute_image" "fortigate" {
  family  = "fortigate-74-payg"
  project = "fortigcp-project-001"
}

resource "google_compute_instance" "firewall" {
  name           = local.firewall_name
  machine_type   = "e2-standard-4"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = true
  project        = var.gcp_project
  metadata = {
    fortigate_user_password = "trace"
    user-data = templatefile("${path.module}/bootstrap2.tpl", {
      hostname         = local.firewall_name
      port1_ip         = google_compute_address.wan.address
      port2_ip         = google_compute_address.lan.address
      port1_gateway    = var.subnets.untrusted-subnet.gateway_address
      port2_gateway    = var.subnets.trusted-subnet.gateway_address
      trusted_subnet   = var.subnets.trusted-subnet.ip_cidr_range
      untrusted_subnet = var.subnets.untrusted-subnet.ip_cidr_range
      elb_ip           = google_compute_address.lb_external.address
      ilb_ip           = google_compute_address.lb_internal.address
      hc_port          = var.hc_port
      protected_subnet = var.vpc_prod_app_cidr_range
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
    subnetwork = var.subnets.untrusted-subnet.self_link

    access_config {
      nat_ip = google_compute_address.wan_external.address
    }
  }

  network_interface { # nic1: LAN Interface
    nic_type   = "VIRTIO_NET"
    network_ip = google_compute_address.lan.address
    subnetwork = var.subnets.trusted-subnet.self_link
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

data "google_compute_zones" "available" {
  region = var.gcp_region
}

data "google_compute_default_service_account" "default" {
}

resource "google_compute_disk" "firewall_boot" {
  image                     = data.google_compute_image.fortigate.self_link
  name                      = "firewall-boot-disk"
  physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = var.boot_disk_size
  type                      = "pd-standard"
  zone                      = data.google_compute_zones.available.names[0]
}
