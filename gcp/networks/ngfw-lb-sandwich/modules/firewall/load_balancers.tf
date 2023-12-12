

/* #### External Load Balancer (using target pool) ###
resource "google_compute_forwarding_rule" "elb" {
  name                  = "trace-test-elb"
  region                = var.gcp_region
  ip_address            = google_compute_address.lb_external.address
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_pool.elb.self_link
}

### Target Pools ###
resource "google_compute_target_pool" "elb" {
  name             = "fgt-instancepool"
  region           = var.gcp_region
  session_affinity = "CLIENT_IP"

  instances = [google_compute_instance.firewall.self_link]

  health_checks = [
    google_compute_http_health_check.elb.name
  ]
}

resource "google_compute_http_health_check" "elb" {
  name                = "health-check-elb-backend"
  check_interval_sec  = 3
  timeout_sec         = 2
  unhealthy_threshold = 3
  port                = var.hc_port
} */

resource "google_compute_forwarding_rule" "ilb" {
  network               = var.vpcs["trusted"].name
  name                  = "trace-test-ilb"
  region                = var.gcp_region
  ip_address            = google_compute_address.lb_internal.address
  subnetwork            = var.subnets.trusted-subnet.self_link
  load_balancing_scheme = "INTERNAL"
  ip_protocol           = "L3_DEFAULT"
  backend_service       = google_compute_region_backend_service.ilb.self_link
  all_ports             = true
}

resource "google_compute_region_health_check" "ilb" {
  name                = "health-check-ilb-backend"
  check_interval_sec  = 3
  timeout_sec         = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = var.hc_port
  }
}
resource "google_compute_region_backend_service" "ilb" {
  name             = "ilb-backend-service"
  region           = var.gcp_region
  network          = var.vpcs["trusted"].name
  session_affinity = "CLIENT_IP"
  protocol         = "UNSPECIFIED"
  backend {
    group = google_compute_instance_group.firewall.self_link
  }
  health_checks = [
    google_compute_region_health_check.ilb.id
  ]

}

resource "google_compute_forwarding_rule" "elb" {
  name                  = "trace-test-elb"
  region                = var.gcp_region
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.lb_external.address
  backend_service       = google_compute_region_backend_service.elb.self_link
  all_ports             = true
  project               = var.gcp_project
  ip_protocol           = "L3_DEFAULT"
}

resource "google_compute_region_backend_service" "elb" {
  name                  = "elb-backend-service"
  region                = var.gcp_region
  session_affinity      = "CLIENT_IP"
  project               = var.gcp_project
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_instance_group.firewall.self_link
  }
  health_checks = [
    google_compute_region_health_check.elb.id
  ]

}

resource "google_compute_region_health_check" "elb" {
  name                = "health-check-elb-backend"
  check_interval_sec  = 3
  timeout_sec         = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = var.hc_port
  }
}
resource "google_compute_instance_group" "firewall" {
  name      = "firewall-instance-group"
  zone      = google_compute_instance.firewall.zone
  instances = [google_compute_instance.firewall.self_link]
}
