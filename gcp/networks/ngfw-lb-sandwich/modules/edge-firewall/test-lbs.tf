/* # Internal Load Balancer
resource "google_compute_address" "ilb" {
  name         = "firewall-ilb-vip"
  address_type = "INTERNAL"
  project      = data.google_client_config.this.project
  ip_version   = "IPV4"
  region       = data.google_client_config.this.region
  subnetwork   = data.google_compute_subnetwork.trusted.self_link
  address      = cidrhost(data.google_compute_subnetwork.trusted.ip_cidr_range, 3)
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

# External Load Balancer
resource "google_compute_address" "elb" {
  name         = "firewall-elb-vip"
  address_type = "EXTERNAL"
  project      = data.google_client_config.this.project
  ip_version   = "IPV4"
  region       = data.google_client_config.this.region
}

resource "google_compute_forwarding_rule" "elb" {
  provider              = google-beta
  name                  = "firewall-elb-fwd-rule"
  backend_service       = google_compute_region_backend_service.elb.id
  ip_protocol           = "L3_DEFAULT"
  ip_address            = google_compute_address.elb.address
  all_ports             = true
  load_balancing_scheme = "EXTERNAL"
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
 */
