

#### External Load Balancer (using target pool) ###
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

### Health Check ###
resource "google_compute_http_health_check" "elb" {
  name                = "health-check-elb-backend"
  check_interval_sec  = 3
  timeout_sec         = 2
  unhealthy_threshold = 3
  port                = "8008"
}


## Alternate External LB
/* resource "google_compute_forwarding_rule" "firewall" {
  name                  = "firewall-lb-fwd-rule"
  region                = var.gcp_region
  ip_address            = google_compute_address.lb_external.address
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "L3_DEFAULT"
  all_ports             = true
  backend_service       = google_compute_region_backend_service.firewall.self_link
}

resource "google_compute_region_health_check" "firewall" {
  name                = "firewall-lb-health-check"
  check_interval_sec  = 3
  timeout_sec         = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = "8008"
  }
}

resource "google_compute_region_backend_service" "firewall" {
  provider              = google-beta
  name                  = "firewall-lb-backend-service"
  region                = var.gcp_region
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "EXTERNAL"
  connection_tracking_policy {
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  }
  backend {
    group = google_compute_instance_group.firewall.self_link
  }
  health_checks = [
    google_compute_region_health_check.firewall.self_link
  ]
} */



