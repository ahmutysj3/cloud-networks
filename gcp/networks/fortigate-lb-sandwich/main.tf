resource "google_compute_network" "trusted" {
  project                                   = var.gcp_project
  name                                      = "test-trusted-vpc-network"
  auto_create_subnetworks                   = false
  delete_default_routes_on_create           = true
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
  enable_ula_internal_ipv6                  = false
  routing_mode                              = "REGIONAL"
}

resource "google_compute_network" "untrusted" {
  project                                   = var.gcp_project
  name                                      = "test-untrusted-vpc-network"
  auto_create_subnetworks                   = false
  delete_default_routes_on_create           = true
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
  enable_ula_internal_ipv6                  = false
  routing_mode                              = "REGIONAL"
}

resource "google_compute_network" "protected" {
  project                                   = var.gcp_project
  name                                      = "test-protected-vpc-network"
  auto_create_subnetworks                   = false
  delete_default_routes_on_create           = true
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
  enable_ula_internal_ipv6                  = false
  routing_mode                              = "REGIONAL"
}

resource "google_compute_network_peering" "trusted" {
  name         = "trusted-to-protected-peering"
  network      = google_compute_network.trusted.self_link
  peer_network = google_compute_network.protected.self_link
}

resource "google_compute_network_peering" "protected" {
  name         = "protected-to-trusted-peering"
  network      = google_compute_network.protected.self_link
  peer_network = google_compute_network.trusted.self_link
}

resource "google_compute_subnetwork" "trusted" {
  project       = var.gcp_project
  name          = "test-trusted-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.trusted.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

resource "google_compute_subnetwork" "untrusted" {
  project       = var.gcp_project
  name          = "test-untrusted-subnet"
  ip_cidr_range = "10.255.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.untrusted.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}
resource "google_compute_route" "untrusted_inet" {
  project          = var.gcp_project
  network          = google_compute_network.untrusted.name
  name             = "untrusted-inet-route"
  dest_range       = "0.0.0.0/0"
  priority         = 1000
  next_hop_gateway = "default-internet-gateway"
}

resource "google_compute_subnetwork" "protected" {
  project       = var.gcp_project
  name          = "test-protected-subnet"
  ip_cidr_range = "192.168.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.protected.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

resource "google_compute_firewall" "untrusted" {
  name      = "untrusted-firewall"
  project   = var.gcp_project
  network   = google_compute_network.untrusted.name
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
  network   = google_compute_network.trusted.name
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

resource "google_compute_firewall" "protected" {
  name      = "protected-firewall"
  project   = var.gcp_project
  network   = google_compute_network.protected.name
  priority  = 1000
  direction = "INGRESS"

  source_ranges = [google_compute_subnetwork.trusted.ip_cidr_range]

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

resource "google_compute_instance" "pfsense" {
  name           = "pfsense-active-fw"
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
    network_ip         = google_compute_address.wan_private.address
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
    automatic_restart  = false
    preemptible        = true
    provisioning_model = "SPOT"
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


resource "google_compute_region_health_check" "pfsense" {
  name               = "pfsense-tcp-health-check"
  description        = "Health check via tcp"
  project            = var.gcp_project
  region             = var.gcp_region
  timeout_sec        = 2
  check_interval_sec = 2
  tcp_health_check {
    port = 443
  }
}

resource "google_compute_region_backend_service" "pfsense_wan" {
  # provider              = google-beta
  region                = var.gcp_region
  project               = var.gcp_project
  name                  = "pfsense-backend-service"
  health_checks         = [google_compute_region_health_check.pfsense.id]
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "EXTERNAL"
  backend {
    group = google_compute_instance_group.pfsense_wan.self_link
  }

}

resource "google_compute_instance_group" "pfsense_wan" {
  project   = var.gcp_project
  zone      = google_compute_instance.pfsense.zone
  name      = "pfsense-instance-group"
  instances = [google_compute_instance.pfsense.self_link]
  network   = google_compute_instance.pfsense.network_interface[0].network
}

resource "google_compute_instance_group" "pfsense_lan" {
  project   = var.gcp_project
  zone      = google_compute_instance.pfsense.zone
  name      = "internal-instance-group"
  instances = [google_compute_instance.pfsense.self_link]
  network   = google_compute_instance.pfsense.network_interface[1].network
}


resource "google_compute_forwarding_rule" "pfsense_lan" {
  name                  = "pfsense-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.lan.address
  ip_protocol           = "L3_DEFAULT"
  backend_service       = google_compute_region_backend_service.pfsense_lan.self_link
  all_ports             = true
  region                = var.gcp_region
}

resource "google_compute_region_backend_service" "pfsense_lan" {
  # provider              = google-beta
  region                = var.gcp_region
  project               = var.gcp_project
  name                  = "pfsense-lan-backend-service"
  health_checks         = [google_compute_region_health_check.pfsense.id]
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "INTERNAL"
  backend {
    group = google_compute_instance_group.pfsense_lan.self_link
  }

}
