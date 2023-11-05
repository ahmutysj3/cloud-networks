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

resource "google_compute_region_backend_service" "pfsense_untrusted" {
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
}

resource "google_compute_forwarding_rule" "pfsense_untrusted" {
  depends_on            = [google_compute_region_backend_service.pfsense_untrusted]
  name                  = "pfsense-external-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_address.external_lb.address
  ip_protocol           = "L3_DEFAULT"
  backend_service       = google_compute_region_backend_service.pfsense_untrusted.self_link
  all_ports             = true
  region                = var.gcp_region
}

# Internal LB

resource "google_compute_region_backend_service" "pfsense_trusted" {
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

resource "google_compute_forwarding_rule" "pfsense_trusted" {
  depends_on            = [google_compute_region_backend_service.pfsense_trusted]
  name                  = "pfsense-trusted-forwarding-rule"
  load_balancing_scheme = "INTERNAL"
  ip_protocol           = "L3_DEFAULT"
  network               = google_compute_network.trusted.self_link
  subnetwork            = google_compute_subnetwork.trusted.self_link
  ip_address            = google_compute_address.internal_lb.address
  backend_service       = google_compute_region_backend_service.pfsense_trusted.self_link
  all_ports             = true
  region                = var.gcp_region
}




