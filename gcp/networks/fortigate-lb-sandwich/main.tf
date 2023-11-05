resource "google_compute_network" "this" {
  project                                   = var.gcp_project
  name                                      = "test-vpc-network"
  auto_create_subnetworks                   = false
  delete_default_routes_on_create           = true
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
  enable_ula_internal_ipv6                  = false
  routing_mode                              = "REGIONAL"
}

resource "google_compute_subnetwork" "trusted" {
  project       = var.gcp_project
  name          = "test-trusted-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.this.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

resource "google_compute_subnetwork" "untrusted" {
  project       = var.gcp_project
  name          = "test-untrusted-subnet"
  ip_cidr_range = "10.255.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.this.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

resource "google_compute_firewall" "untrusted" {
  name      = "untrusted-firewall"
  project   = var.gcp_project
  network   = google_compute_network.this.name
  priority  = 1000
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "trusted" {
  name      = "trusted-firewall"
  project   = var.gcp_project
  network   = google_compute_network.this.name
  priority  = 1000
  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "all"
  }
}

data "google_compute_zones" "available" {
  region = var.gcp_region
}

data "google_compute_default_service_account" "default" {
}
/* 
resource "random_string" "initial_password" {
  length  = 30
  special = true
}

resource "google_compute_instance" "pfsense" {
  name           = "pfsense-active-fw"
  machine_type   = "e2-standard-4"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = "true"
  project        = var.gcp_project
  metadata = {
    ATTACHED_DISKS           = "log-disk"
    enable-oslogin           = "true"
    google-logging-enable    = "0"
    google-monitoring-enable = "0"
    ssh-keys                 = "trace:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjI2kHRd2kAMmb8wbVmu66q/MfHhGiop6tZ1s7e9iJ+TzOK0S92cfIxrBTu08J6MhTg/CUfZwHe6WKB3sA5A2tWOLLpYdkvvwAojOh0z7hD9l8UZ57agRu0aaVfOofQwhQBWZFiOWIOUWmLAtHCxejV24ICJt/+pk1D+0MhqulKccC1Si7RZgzBqGzeH64mwgTbbl/QD3Hf2NcT5PvUZL9yWJDonoh1CZ5j4SfU/YJBBQXXsI3LJkH5gGCz2+CY+ZhZbtnCLrDMsgzK9uUSamdZ7bIiBi0LAM8P9O+QK75kBwnyRvQly92sIP50uxMGAfI8D/MfmHoP9pcTmHFbWcv trace@trace-laptop"
  }


  attached_disk {
    device_name = "log-disk"
    mode        = "READ_WRITE"
    source      = google_compute_disk.pfsense_log.self_link
  }

  boot_disk {
    auto_delete = true
    device_name = "boot-disk"
    mode        = "READ_WRITE"
    source      = google_compute_disk.pfsense_boot.self_link
  }


  network_interface { # nic0: WAN Interface
    access_config {
      nat_ip       = google_compute_address.wan_external.address
      network_tier = "PREMIUM"
    }

    nic_type           = "VIRTIO_NET"
    network            = google_compute_network.untrusted.self_link
    network_ip         = google_compute_address.fw_wan.address
    stack_type         = "IPV4_ONLY"
    subnetwork         = google_compute_subnetwork.untrusted.self_link
    subnetwork_project = var.gcp_project
  }

  network_interface { # nic1: LAN Interface
    nic_type           = "VIRTIO_NET"
    network            = google_compute_network.trusted.self_link
    network_ip         = google_compute_address.lan.address
    stack_type         = "IPV4_ONLY"
    subnetwork         = google_compute_subnetwork.trusted.self_link
    subnetwork_project = var.gcp_project
  }

  scheduling { # Discounted Rates
    automatic_restart  = false
    preemptible        = true
    provisioning_model = "SPOT"
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_vtpm                 = true
  }

} */

/* resource "google_compute_disk" "pfsense_boot" {
  image                     = data.google_compute_image.pfsense.self_link
  name                      = "pfsense-boot-disk"
  physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = var.boot_disk_size
  type                      = "pd-standard"
  zone                      = data.google_compute_zones.available.names[0]
} */

data "google_storage_bucket_object" "picture" {
  name   = "pfsense.2.7.img.tar.gz"
  bucket = "trace-main"
}

resource "google_compute_address" "lan" {
  name         = "fw-lan-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.trusted.self_link
  address      = cidrhost(google_compute_subnetwork.trusted.ip_cidr_range, 2)
}

resource "google_compute_address" "wan_private" {
  name         = "fw-wan-internal-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.untrusted.self_link
  address      = cidrhost(google_compute_subnetwork.untrusted.ip_cidr_range, 2)
}

resource "google_compute_address" "wan_external" {
  name         = "fw-wan-external-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  region       = var.gcp_region
}
