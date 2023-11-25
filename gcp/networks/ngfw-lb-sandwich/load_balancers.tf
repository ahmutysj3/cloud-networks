# Health Check

/* resource "google_compute_region_health_check" "firewall" {
  name               = "firewall-tcp-health-check"
  description        = "Health check via tcp"
  project            = var.gcp_project
  region             = var.gcp_region
  timeout_sec        = 2
  check_interval_sec = 60
  tcp_health_check {
    port = 443
  }
}
 */

/* resource "google_compute_http_health_check" "firewall" {
  name               = "firewall-http-health-check"
  project            = var.gcp_project
  check_interval_sec = 3
  timeout_sec        = 2
  healthy_threshold  = 3
  port               = "8008"
}


resource "google_compute_forwarding_rule" "firewall" {
  name                  = "firewall-forwarding-rule"
  region                = var.gcp_region
  project               = var.gcp_project
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.external_lb.address

  target = google_compute_target_pool.firewall.self_link
}

resource "google_compute_target_pool" "firewall" {
  name             = "firewall-target-pool"
  region           = var.gcp_region
  project          = var.gcp_project
  session_affinity = "CLIENT_IP"
  health_checks    = [google_compute_http_health_check.firewall.id]
  instances        = [google_compute_instance.fortigate.self_link]
} */

# External LB

/* resource "google_compute_region_backend_service" "elb" {
  provider              = google-beta
  depends_on            = [google_compute_instance.fortigate]
  region                = var.gcp_region
  project               = var.gcp_project
  name                  = "firewall-untrusted-backend-service"
  health_checks         = [google_compute_region_health_check.firewall.id]
  protocol              = "TCP"
  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"
  backend {
    group = google_compute_instance_group.fortigate.self_link

  }
}

resource "google_compute_forwarding_rule" "elb" {
  depends_on            = [google_compute_region_backend_service.elb]
  name                  = "firewall-external-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.external_lb.address
  ip_protocol           = "TCP"
  backend_service       = google_compute_region_backend_service.elb.self_link
  all_ports             = true
  region                = var.gcp_region
} */

# Internal LB

/* resource "google_compute_region_backend_service" "ilb" {
  depends_on            = [google_compute_instance.fortigate]
  region                = var.gcp_region
  project               = var.gcp_project
  network               = google_compute_network.trusted.self_link
  name                  = "firewall-trusted-backend-service"
  health_checks         = [google_compute_region_health_check.firewall.id]
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  backend {
    group = google_compute_instance_group.fortigate.self_link
  }
}

resource "google_compute_forwarding_rule" "ilb" {
  depends_on            = [google_compute_region_backend_service.ilb]
  name                  = "firewall-trusted-forwarding-rule"
  load_balancing_scheme = "INTERNAL"
  ip_protocol           = "TCP"
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
 */
