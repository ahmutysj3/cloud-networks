resource "google_compute_instance" "pfsense" {
  name           = "pfsense-active1-fw"
  machine_type   = "e2-standard-4"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = true
  project        = var.gcp_project
  metadata = {
    # enable-oslogin           = true
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
    nic_type   = "VIRTIO_NET"
    network_ip = google_compute_address.wan.address
    subnetwork = google_compute_subnetwork.untrusted.self_link
  }

  network_interface { # nic1: LAN Interface
    nic_type   = "VIRTIO_NET"
    network_ip = google_compute_address.lan.address
    subnetwork = google_compute_subnetwork.trusted.self_link
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

resource "google_compute_instance_group" "pfsense" {
  depends_on = [google_compute_instance.pfsense]
  name       = "pfsense-instance-group"
  zone       = data.google_compute_zones.available.names[0]
  instances  = [google_compute_instance.pfsense.self_link]
}
resource "google_compute_network" "trusted" {
  project                         = var.gcp_project
  name                            = "test-trusted-vpc-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true

}

resource "google_compute_network" "untrusted" {
  project                         = var.gcp_project
  name                            = "test-untrusted-vpc-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false

}

resource "google_compute_network" "protected" {
  project                         = var.gcp_project
  name                            = "test-protected-vpc-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_network_peering" "trusted" {
  name                 = "trusted-to-protected-peering"
  network              = google_compute_network.trusted.self_link
  peer_network         = google_compute_network.protected.self_link
  import_custom_routes = false
  export_custom_routes = true
}

resource "google_compute_network_peering" "protected" {
  depends_on           = [google_compute_network_peering.trusted]
  name                 = "protected-to-trusted-peering"
  network              = google_compute_network.protected.self_link
  peer_network         = google_compute_network.trusted.self_link
  import_custom_routes = true
  export_custom_routes = false
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

resource "google_compute_subnetwork" "protected" {
  project       = var.gcp_project
  name          = "test-protected-subnet"
  ip_cidr_range = "192.168.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.protected.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}
data "google_compute_zones" "available" {
  region = var.gcp_region
}

data "google_compute_default_service_account" "default" {
}
# Health Check

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

# External LB

resource "google_compute_region_backend_service" "elb" {
  provider              = google-beta
  depends_on            = [google_compute_instance.pfsense]
  region                = var.gcp_region
  project               = var.gcp_project
  name                  = "pfsense-untrusted-backend-service"
  health_checks         = [google_compute_region_health_check.pfsense.id]
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "EXTERNAL"
  backend {
    group = google_compute_instance_group.pfsense.self_link
  }
  connection_tracking_policy {
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  }
}

resource "google_compute_forwarding_rule" "elb" {
  depends_on            = [google_compute_region_backend_service.elb]
  name                  = "pfsense-external-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.external_lb.address
  ip_protocol           = "L3_DEFAULT"
  backend_service       = google_compute_region_backend_service.elb.self_link
  all_ports             = true
  region                = var.gcp_region
}

# Internal LB

resource "google_compute_region_backend_service" "ilb" {
  depends_on            = [google_compute_instance.pfsense]
  region                = var.gcp_region
  project               = var.gcp_project
  network               = google_compute_network.trusted.self_link
  name                  = "pfsense-trusted-backend-service"
  health_checks         = [google_compute_region_health_check.pfsense.id]
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "INTERNAL"
  backend {
    group = google_compute_instance_group.pfsense.self_link
  }
}

resource "google_compute_forwarding_rule" "ilb" {
  depends_on            = [google_compute_region_backend_service.ilb]
  name                  = "pfsense-trusted-forwarding-rule"
  load_balancing_scheme = "INTERNAL"
  ip_protocol           = "L3_DEFAULT"
  network               = google_compute_network.trusted.self_link
  subnetwork            = google_compute_subnetwork.trusted.id
  ip_address            = google_compute_address.internal_lb.address
  backend_service       = google_compute_region_backend_service.ilb.self_link
  all_ports             = true
  region                = var.gcp_region
}


resource "google_compute_route" "default_route" {
  name         = "default-route-via-fw"
  network      = google_compute_network.trusted.self_link
  dest_range   = "0.0.0.0/0"
  priority     = 100
  next_hop_ilb = google_compute_forwarding_rule.ilb.ip_address
}

resource "google_compute_firewall" "untrusted" {
  name      = "default-allow-all-untrusted"
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
  name      = "default-allow-all-trusted"
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
  name      = "allow-all-from-trusted-to-protected"
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

resource "google_compute_firewall" "health_checks" {
  name      = "default-allow-health-checks"
  project   = var.gcp_project
  network   = google_compute_network.trusted.name
  priority  = 1000
  direction = "INGRESS"

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
resource "google_compute_router" "this" {
  name    = "trace-test-cloud-router"
  region  = var.gcp_region
  project = var.gcp_project
  network = google_compute_network.untrusted.name
}

resource "google_compute_router_nat" "this" {
  name                               = "${google_compute_router.this.name}-nat"
  router                             = google_compute_router.this.name
  region                             = var.gcp_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
resource "google_compute_address" "lan" {
  name         = "fw-lan-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.trusted.self_link
  address      = cidrhost(google_compute_subnetwork.trusted.ip_cidr_range, 2)
}

resource "google_compute_address" "wan" {
  name         = "fw-wan-internal-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.untrusted.self_link
  address      = cidrhost(google_compute_subnetwork.untrusted.ip_cidr_range, 2)
}

resource "google_compute_address" "external_lb" {
  name         = "external-lb-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  region       = var.gcp_region
}

resource "google_compute_address" "internal_lb" {
  name         = "internal-lb-ip"
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.trusted.self_link
  purpose      = "GCE_ENDPOINT"
  region       = var.gcp_region
  address      = cidrhost(google_compute_subnetwork.trusted.ip_cidr_range, 255)

}
