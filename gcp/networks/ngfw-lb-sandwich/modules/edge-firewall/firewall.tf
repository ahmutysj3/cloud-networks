locals {
  firewall_name = "${var.model}-firewall"

  fw_gateways = {
    untrusted = var.fw_network_interfaces[0].gateway
    trusted   = var.fw_network_interfaces[1].gateway
  }

  firewall_images = {
    pfsense   = data.google_compute_image.pfsense.self_link
    fortigate = data.google_compute_image.fortigate.self_link
  }
}

data "google_client_config" "this" {
}

data "google_compute_zones" "available" {
  region = data.google_client_config.this.region
}

data "google_compute_default_service_account" "default" {
}

data "google_compute_image" "pfsense" {
  project = data.google_client_config.this.project
  name    = "pfsense-272-fully-configured-image"
}

data "google_compute_image" "fortigate" {
  family  = "fortigate-74-payg"
  project = "fortigcp-project-001"
}


resource "google_compute_address" "elb" {
  name         = "firewall-elb-vip"
  address_type = "EXTERNAL"
  project      = data.google_client_config.this.project
  ip_version   = "IPV4"
  region       = data.google_client_config.this.region
}

resource "google_compute_address" "test" {
  name         = "fw-test-external-ip"
  address_type = "EXTERNAL"
  project      = data.google_client_config.this.project
  ip_version   = "IPV4"
  region       = data.google_client_config.this.region
}

data "google_compute_subnetwork" "trusted" {
  project   = data.google_client_config.this.project
  self_link = var.fw_network_interfaces[1].subnet
}

resource "google_compute_address" "ilb" {
  name         = "firewall-ilb-vip"
  address_type = "INTERNAL"
  project      = data.google_client_config.this.project
  ip_version   = "IPV4"
  region       = data.google_client_config.this.region
  subnetwork   = data.google_compute_subnetwork.trusted.self_link
  #network      = data.google_compute_network.trusted.self_link
  address = cidrhost(data.google_compute_subnetwork.trusted.ip_cidr_range, 3)
}

resource "google_compute_forwarding_rule" "ilb" {
  provider              = google-beta
  name                  = "firewall-ilb-fwd-rule"
  load_balancing_scheme = "INTERNAL"
  project               = data.google_client_config.this.project
  network               = data.google_compute_network.trusted.self_link
  subnetwork            = google_compute_instance.this.network_interface[1].subnetwork
  ip_protocol           = "L3_DEFAULT"
  all_ports             = true
  ip_address            = google_compute_address.ilb.address
  backend_service       = google_compute_region_backend_service.ilb.id
}

resource "google_compute_region_health_check" "ilb" {
  provider            = google-beta
  project             = data.google_client_config.this.project
  name                = "firewall-ilb-health-check"
  region              = data.google_client_config.this.region
  timeout_sec         = 3
  check_interval_sec  = 5
  unhealthy_threshold = 2

  tcp_health_check {
    port = 8001
  }
}

data "google_compute_network" "trusted" {
  project = data.google_client_config.this.project
  name    = var.fw_network_interfaces[1].vpc
}

resource "google_compute_route" "this" {
  provider    = google
  name        = "default-fw-ilbnh-route"
  network     = data.google_compute_network.trusted.self_link
  dest_range  = "0.0.0.0/0"
  priority    = 100
  next_hop_ip = google_compute_forwarding_rule.ilb.ip_address

}

resource "google_compute_region_backend_service" "ilb" {
  provider              = google-beta
  project               = data.google_client_config.this.project
  region                = data.google_client_config.this.region
  name                  = "firewall-ilb"
  health_checks         = [google_compute_region_health_check.ilb.id]
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "INTERNAL"
  network               = data.google_compute_network.trusted.self_link
  session_affinity      = "NONE"

  backend {
    group = google_compute_instance_group.this.self_link
  }
}

resource "google_compute_forwarding_rule" "elb" {
  provider        = google-beta
  name            = "firewall-elb-fwd-rule"
  backend_service = google_compute_region_backend_service.elb.id
  ip_protocol     = "L3_DEFAULT"
  ip_address      = google_compute_address.elb.address
  all_ports       = true
}

resource "google_compute_region_backend_service" "elb" {
  provider              = google-beta
  region                = data.google_client_config.this.region
  name                  = "firewall-elb"
  health_checks         = [google_compute_region_health_check.elb.id]
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_instance_group.this.self_link
  }

}

resource "google_compute_region_health_check" "elb" {
  provider            = google-beta
  name                = "firewall-elb-health-check"
  region              = data.google_client_config.this.region
  timeout_sec         = 3
  check_interval_sec  = 5
  unhealthy_threshold = 2

  tcp_health_check {
    port = 8001
  }
}

resource "google_compute_instance_group" "this" {
  provider  = google
  name      = "firewall-elb-instance-group"
  zone      = google_compute_instance.this.zone
  instances = [google_compute_instance.this.id]
}

resource "google_compute_instance" "this" {
  name           = local.firewall_name
  machine_type   = "n1-standard-2"
  zone           = data.google_compute_zones.available.names[0]
  can_ip_forward = true
  project        = data.google_client_config.this.project
  metadata = {
    serial-port-enable = "TRUE"
    ssh-keys           = var.ssh_public_key
  }

  tags = ["firewall"]

  boot_disk {
    auto_delete = true
    device_name = "boot-disk"
    mode        = "READ_WRITE"
    source      = google_compute_disk.firewall_boot.self_link
  }

  dynamic "network_interface" {
    for_each = var.fw_network_interfaces
    content {
      nic_type   = "VIRTIO_NET"
      network    = network_interface.value.vpc
      subnetwork = network_interface.value.subnet
      network_ip = network_interface.value.ip_addr

      dynamic "access_config" {
        for_each = network_interface.value.vpc == "untrusted-vpc" ? [1] : []
        content {
          nat_ip = google_compute_address.test.address
        }
      }
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

resource "google_compute_disk" "firewall_boot" {
  image                     = local.firewall_images[var.model]
  name                      = "firewall-boot-disk"
  physical_block_size_bytes = 4096
  project                   = data.google_client_config.this.project
  size                      = 50
  type                      = "pd-standard"
  zone                      = data.google_compute_zones.available.names[0]
}
