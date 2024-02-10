data "google_compute_instance" "this" {
  project = var.vm_project
  zone    = data.google_compute_zones.this.names[0]
  name    = var.instance_name
}

data "google_compute_zones" "this" {
  region = var.gcp_region
}
data "google_compute_network" "this" {
  project = var.network_project
  name    = var.vpc_name
}

data "google_compute_subnetwork" "this" {
  project = var.network_project
  region  = var.gcp_region
  name    = var.subnetwork_name
}

variable "subnetwork_name" {
  description = "The name of the subnetwork to use for the instance."
  type        = string

}

variable "vm_project" {
  description = "The project to create the instance in"
  type        = string

}

variable "instance_name" {
  description = "The name of the instance"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC to use for the instance."
  type        = string
}

variable "network_project" {
  description = "The project to create the instance in"
  type        = string

}

variable "gcp_region" {
  description = "The region to create the instance in"
  type        = string
}

variable "name_prefix" {
  type    = string
  default = "trace"
}

locals {
  resources = ["fwd_rule", "target_https_proxy", "url_map", "backend_service", "instance_group", "health_check"]
  names     = { for k, v in local.resources : v => replace("${var.name_prefix}-${v}", "_", "-") }
}

resource "google_compute_forwarding_rule" "this" {
  provider              = google-beta
  name                  = local.names["fwd_rule"]
  region                = var.gcp_region
  project               = var.vm_project
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_region_target_https_proxy.this.id
  network               = data.google_compute_network.this.id
  subnetwork            = data.google_compute_subnetwork.this.id
  network_tier          = "PREMIUM"
}

resource "google_compute_region_target_https_proxy" "this" {
  provider = google-beta
  name     = local.names["target_https_proxy"]
  region   = var.gcp_region

  ssl_certificates = [data.google_compute_ssl_certificate.this.id]
  url_map          = google_compute_region_url_map.this.id

}

resource "google_compute_region_url_map" "this" {
  region = var.gcp_region

  project = var.vm_project
  name    = local.names["url_map"]

  default_service = google_compute_region_backend_service.this.id

  host_rule {
    hosts        = ["tracecloud.us"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_region_backend_service.this.id

    path_rule {
      paths   = ["/"]
      service = google_compute_region_backend_service.this.id
    }
  }
}

resource "google_compute_region_backend_service" "this" {
  name                  = local.names["backend_service"]
  project               = var.vm_project
  region                = var.gcp_region
  health_checks         = [google_compute_region_health_check.this.id]
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTPS"
  locality_lb_policy    = "ROUND_ROBIN"

  backend {
    group           = google_compute_instance_group.this.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}


resource "google_compute_region_health_check" "this" {
  name = local.names["health_check"]

  tcp_health_check {
    port = 443
  }
}

resource "google_compute_instance_group" "this" {
  name        = local.names["instance_group"]
  project     = var.vm_project
  network     = data.google_compute_network.this.id
  zone        = data.google_compute_instance.this.zone
  description = "Instance group for the internal load balancer"

  named_port {
    name = "https"
    port = 443
  }
  instances = [data.google_compute_instance.this.id]
}
data "google_compute_ssl_certificate" "this" {
  project = "trace-terraform-perm"
  name    = "test-lb-ssl-cert"
}
