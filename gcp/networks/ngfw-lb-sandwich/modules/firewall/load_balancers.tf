

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
  port                = var.hc_port
}



