resource "google_compute_address" "app_ilb_vip" {
  name         = "l7-ilb-vip"
  subnetwork   = google_compute_subnetwork.ilb.self_link
  address_type = "INTERNAL"
  address      = cidrhost(google_compute_subnetwork.ilb.ip_cidr_range, 2)
  region       = var.gcp_region
  purpose      = "SHARED_LOADBALANCER_VIP"
}

/* 
# Regional forwarding rule
resource "google_compute_forwarding_rule" "app_ilb" {
  name                  = "l7-ilb-forwarding-rule"
  region                = var.gcp_region
  depends_on            = [google_compute_subnetwork.proxy]
  ip_protocol           = "TCP"
  ip_address            = google_compute_address.app_ilb_vip.address
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_region_target_https_proxy.this.id
  network               = google_compute_network.protected.id
  subnetwork            = google_compute_subnetwork.ilb.self_link
  network_tier          = "PREMIUM"
}
# Regional target HTTPS proxy
resource "google_compute_region_target_https_proxy" "default" {
  name             = "l7-ilb-target-https-proxy"
  region           = "europe-west1"
  url_map          = google_compute_region_url_map.https_lb.id
  ssl_certificates = [google_compute_region_ssl_certificate.default.self_link]
}

# Regional URL map
resource "google_compute_region_url_map" "https_lb" {
  name            = "l7-ilb-regional-url-map"
  region          = "europe-west1"
  default_service = google_compute_region_backend_service.default.id
}

# Regional backend service
resource "google_compute_region_backend_service" "default" {
  name                  = "l7-ilb-backend-service"
  region                = "europe-west1"
  protocol              = "HTTP"
  port_name             = "http-server"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.default.id]
  backend {
    group           = google_compute_region_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# Instance template
resource "google_compute_instance_template" "default" {
  name         = "l7-ilb-mig-template"
  machine_type = "e2-small"
  tags         = ["http-server"]
  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF
    EOF1
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Regional health check
resource "google_compute_region_health_check" "default" {
  name   = "l7-ilb-hc"
  region = "europe-west1"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

# Regional MIG
resource "google_compute_region_instance_group_manager" "default" {
  name   = "l7-ilb-mig1"
  region = "europe-west1"
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  named_port {
    name = "http-server"
    port = 80
  }
  base_instance_name = "vm"
  target_size        = 2
}

# Allow all access to health check ranges
resource "google_compute_firewall" "default" {
  name          = "l7-ilb-fw-allow-hc"
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
  }
}

# Allow http from proxy subnet to backends
resource "google_compute_firewall" "backends" {
  name          = "l7-ilb-fw-allow-ilb-to-backends"
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  source_ranges = ["10.0.0.0/24"]
  target_tags   = ["http-server"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
}

# Test instance
resource "google_compute_instance" "default" {
  name         = "l7-ilb-test-vm"
  zone         = "europe-west1-b"
  machine_type = "e2-small"
  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
}

### HTTP-to-HTTPS redirect ###

# Regional forwarding rule
resource "google_compute_forwarding_rule" "redirect" {
  name                  = "l7-ilb-redirect"
  region                = "europe-west1"
  ip_protocol           = "TCP"
  ip_address            = google_compute_address.default.id # Same as HTTPS load balancer
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.default.id
  subnetwork            = google_compute_subnetwork.default.id
  network_tier          = "PREMIUM"
}

# Regional HTTP proxy
resource "google_compute_region_target_http_proxy" "default" {
  name    = "l7-ilb-target-http-proxy"
  region  = "europe-west1"
  url_map = google_compute_region_url_map.redirect.id
}

# Regional URL map
resource "google_compute_region_url_map" "redirect" {
  name            = "l7-ilb-redirect-url-map"
  region          = "europe-west1"
  default_service = google_compute_region_backend_service.default.id
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_region_backend_service.default.id
    path_rule {
      paths = ["/"]
      url_redirect {
        https_redirect         = true
        host_redirect          = "10.0.1.5:443"
        redirect_response_code = "PERMANENT_REDIRECT"
        strip_query            = true
      }
    }
  }
}
 */
