data "google_compute_image" "palo_alto" {
  project = "paloaltonetworksgcp-public"
  name    = "vmseries-flex-bundle1-mp-1022h2"
}

resource "google_compute_instance" "palo_alto" {
  name           = "palo-alto-active1-fw"
  machine_type   = "n2-standard-4"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = true
  project        = var.gcp_project
  metadata = {
    google-logging-enable    = "0"
    google-monitoring-enable = "0"
    ssh-keys                 = "trace:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjI2kHRd2kAMmb8wbVmu66q/MfHhGiop6tZ1s7e9iJ+TzOK0S92cfIxrBTu08J6MhTg/CUfZwHe6WKB3sA5A2tWOLLpYdkvvwAojOh0z7hD9l8UZ57agRu0aaVfOofQwhQBWZFiOWIOUWmLAtHCxejV24ICJt/+pk1D+0MhqulKccC1Si7RZgzBqGzeH64mwgTbbl/QD3Hf2NcT5PvUZL9yWJDonoh1CZ5j4SfU/YJBBQXXsI3LJkH5gGCz2+CY+ZhZbtnCLrDMsgzK9uUSamdZ7bIiBi0LAM8P9O+QK75kBwnyRvQly92sIP50uxMGAfI8D/MfmHoP9pcTmHFbWcv trace@trace-laptop"
  }

  boot_disk {
    auto_delete = true
    device_name = "boot-disk"
    mode        = "READ_WRITE"
    source      = google_compute_disk.palo_alto_boot.self_link
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

resource "google_compute_disk" "palo_alto_boot" {
  image                     = data.google_compute_image.palo_alto.self_link
  name                      = "palo-alto-boot-disk"
  physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = var.boot_disk_size
  type                      = "pd-standard"
  zone                      = data.google_compute_zones.available.names[0]
}


resource "google_compute_instance_group" "palo_alto" {
  depends_on = [google_compute_instance.palo_alto]
  name       = "palo-alto-instance-group"
  zone       = data.google_compute_zones.available.names[0]
  instances  = [google_compute_instance.palo_alto.self_link]
}

# Health Check

resource "google_compute_region_health_check" "palo_alto" {
  name               = "palo-alto-tcp-health-check"
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
  depends_on            = [google_compute_instance.palo_alto]
  region                = var.gcp_region
  project               = var.gcp_project
  name                  = "palo-alto-untrusted-backend-service"
  health_checks         = [google_compute_region_health_check.palo_alto.id]
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "EXTERNAL"
  backend {
    group = google_compute_instance_group.palo_alto.self_link
  }
  connection_tracking_policy {
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  }
}

resource "google_compute_forwarding_rule" "elb" {
  depends_on            = [google_compute_region_backend_service.elb]
  name                  = "palo-alto-external-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.external_lb.address
  ip_protocol           = "L3_DEFAULT"
  backend_service       = google_compute_region_backend_service.elb.self_link
  all_ports             = true
  region                = var.gcp_region
}

# Internal LB

resource "google_compute_region_backend_service" "ilb" {
  depends_on            = [google_compute_instance.palo_alto]
  region                = var.gcp_region
  project               = var.gcp_project
  network               = google_compute_network.trusted.self_link
  name                  = "palo-alto-trusted-backend-service"
  health_checks         = [google_compute_region_health_check.palo_alto.id]
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "INTERNAL"
  backend {
    group = google_compute_instance_group.palo_alto.self_link
  }
}

resource "google_compute_forwarding_rule" "ilb" {
  depends_on            = [google_compute_region_backend_service.ilb]
  name                  = "palo-alto-trusted-forwarding-rule"
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

