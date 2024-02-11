locals {
  address = {
    name         = "firewall-${var.lb_type}-vip"
    address_type = var.lb_type == "ilb" ? "INTERNAL" : "EXTERNAL"
    subnetwork   = var.lb_type == "ilb" ? data.google_compute_subnetwork.trusted.self_link : null
    lb_vip       = var.lb_type == "ilb" ? cidrhost(data.google_compute_subnetwork.trusted.ip_cidr_range, 3) : null
  }
  fwd_rule = {
    name                  = "firewall-${var.lb_type}-fwd-rule"
    load_balancing_scheme = var.lb_type == "ilb" ? "INTERNAL" : "EXTERNAL"
    subnetwork            = var.lb_type == "ilb" ? data.google_compute_subnetwork.trusted.self_link : null
    network               = var.lb_type == "ilb" ? data.google_compute_network.trusted.self_link : null
  }
  backend_service = {
    name                  = "firewall-${var.lb_type}"
    load_balancing_scheme = var.lb_type == "ilb" ? "INTERNAL" : "EXTERNAL"
    network               = var.lb_type == "ilb" ? data.google_compute_network.trusted.self_link : null
  }
}

data "google_client_config" "this" {
}

data "google_compute_network" "trusted" {
  project = data.google_client_config.this.project
  name    = var.trusted_network
}

data "google_compute_subnetwork" "trusted" {
  project   = data.google_client_config.this.project
  self_link = var.trusted_subnet
}

resource "google_compute_address" "this" {
  name         = local.address.name
  address_type = local.address.address_type
  project      = data.google_client_config.this.project
  ip_version   = "IPV4"
  region       = data.google_client_config.this.region
  subnetwork   = local.address.subnetwork
  address      = local.address.lb_vip
}

resource "google_compute_forwarding_rule" "this" {
  provider              = google-beta
  name                  = local.fwd_rule.name
  load_balancing_scheme = local.fwd_rule.load_balancing_scheme
  project               = data.google_client_config.this.project
  network               = local.fwd_rule.network
  subnetwork            = local.fwd_rule.subnetwork
  ip_protocol           = "TCP"
  all_ports             = true
  ip_address            = google_compute_address.this.address
  backend_service       = google_compute_region_backend_service.this.id
}

resource "google_compute_region_health_check" "this" {
  provider            = google-beta
  project             = data.google_client_config.this.project
  name                = "firewall-${var.lb_type}-health-check"
  region              = data.google_client_config.this.region
  timeout_sec         = 3
  check_interval_sec  = 5
  unhealthy_threshold = 2

  tcp_health_check {
    port = var.hc_port
  }
}

resource "google_compute_region_backend_service" "this" {
  provider              = google-beta
  project               = data.google_client_config.this.project
  region                = data.google_client_config.this.region
  name                  = local.backend_service.name
  health_checks         = [google_compute_region_health_check.this.self_link]
  protocol              = "TCP"
  load_balancing_scheme = local.backend_service.load_balancing_scheme
  network               = local.backend_service.network
  session_affinity      = "NONE"

  backend {
    group = var.instance_group_self_link
  }
}

/* resource "google_compute_route" "this" {
  count       = var.lb_type == "ilb" ? 1 : 0
  provider    = google
  name        = "default-fw-ilbnh-route"
  network     = data.google_compute_network.trusted.self_link
  dest_range  = "0.0.0.0/0"
  priority    = 100
  next_hop_ip = google_compute_forwarding_rule.this.ip_address
} */

resource "google_compute_route" "this" {
  count        = var.lb_type == "ilb" ? 1 : 0
  provider     = google-beta
  name         = "default-fw-ilb-route"
  network      = data.google_compute_network.trusted.self_link
  dest_range   = "0.0.0.0/0"
  priority     = 100
  next_hop_ilb = google_compute_forwarding_rule.this.ip_address

}

