/* resource "google_compute_region_backend_service" "elb" {
  provider              = google-beta
  name                  = "${var.name}-elb-backend-service"
  project               = var.project_id
  protocol              = "UNSPECIFIED"
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_region_health_check.this.self_link]

  dynamic "backend" {
    for_each = [for firewalls in module.fw_instances : firewalls.instance_group]
    content {
      group = backend.value
    }
  }

  connection_tracking_policy {
    tracking_mode                                = "PER_SESSION"
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  }
}

resource "google_compute_forwarding_rule" "elb" {
  name                  = "${var.name}-vmseries-extlb-rule1"
  project               = var.project_id
  region                = var.region
  load_balancing_scheme = "EXTERNAL"
  all_ports             = true
  ip_address            = google_compute_address.elb_fw_vip.address
  ip_protocol           = "L3_DEFAULT"
  backend_service       = google_compute_region_backend_service.elb.self_link
}

resource "google_compute_address" "ilb_next_hop" {
  name         = "${var.name}-ilb-next-hop"
  project      = var.project_id
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.this[3].self_link
}

resource "google_compute_forwarding_rule" "ilb" {
  project               = var.project_id
  name                  = "${var.name}-vmseries-ilb-rule1"
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.ilb_next_hop.address
  ip_protocol           = "TCP"
  all_ports             = true
  subnetwork            = data.google_compute_subnetwork.this[3].self_link
  allow_global_access   = true
  backend_service       = google_compute_region_backend_service.ilb.self_link
}

resource "google_compute_region_backend_service" "ilb" {
  provider              = google-beta
  project               = var.project_id
  region                = var.region
  name                  = "${var.name}-vmseries-ilb"
  health_checks         = [google_compute_region_health_check.this.self_link]
  load_balancing_scheme = "INTERNAL"
  network               = data.google_compute_subnetwork.this[3].network
  session_affinity      = null

  dynamic "backend" {
    for_each = [for firewalls in module.fw_instances : firewalls.instance_group]
    content {
      group    = backend.value
      failover = false
    }
  }

  connection_tracking_policy {
    tracking_mode                                = "PER_SESSION"
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
    idle_timeout_sec                             = 600
  }
}

resource "google_compute_route" "ilb_next_hop" {
  name         = "${var.name}-ilb-next-hop-route"
  project      = var.project_id
  network      = data.google_compute_subnetwork.this[3].network
  dest_range   = "0.0.0.0/0"
  next_hop_ilb = google_compute_forwarding_rule.ilb.self_link

}

resource "google_compute_address" "elb_fw_vip" {
  name         = "${var.name}-nat-ip"
  project      = var.project_id
  address_type = "EXTERNAL"
}

resource "google_compute_region_health_check" "this" {
  name                = "${var.name}-vmseries-extlb-hc"
  project             = var.project_id
  region              = var.region
  check_interval_sec  = 3
  healthy_threshold   = 1
  timeout_sec         = 1
  unhealthy_threshold = 1

  http_health_check {
    port         = 80
    request_path = "/php/login.php"
  }
} */
