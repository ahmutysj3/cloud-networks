data "google_compute_network" "this" {
  project = var.network_project
  name    = var.vpc_name
}

data "google_compute_subnetwork" "this" {
  project = var.network_project
  region  = var.gcp_region
  name    = var.subnetwork_name
}

data "google_compute_instance" "this" {
  project = var.vm_project
  zone    = var.vm_zone
  name    = var.vm_name
}

resource "google_compute_global_address" "this" {
  name         = "elb-ip"
  project      = var.vm_project
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "this" {
  name                  = "elb-forwarding-rule"
  project               = var.vm_project
  target                = google_compute_target_https_proxy.this.id
  ip_protocol           = "TCP"
  port_range            = "443"
  ip_address            = google_compute_global_address.this.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_target_https_proxy" "this" {
  name            = "elb-target-https-proxy"
  project         = var.vm_project
  url_map         = google_compute_url_map.this.id
  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.this.id}"
}

resource "google_compute_url_map" "this" {
  name            = "elb-url-map"
  project         = var.vm_project
  default_service = google_compute_backend_service.this.id
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.this.id
  }
}



resource "google_compute_backend_service" "this" {
  name                            = "backend-service"
  project                         = var.vm_project
  health_checks                   = [google_compute_health_check.this.id]
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  protocol                        = "HTTPS"
  timeout_sec                     = 10
  port_name                       = "https"
  session_affinity                = "NONE"
  enable_cdn                      = false
  security_policy                 = null
  connection_draining_timeout_sec = 300
  locality_lb_policy              = "ROUND_ROBIN"

  log_config {
    enable = true
  }

  backend {
    group           = google_compute_instance_group.this.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.8
  }
}



resource "google_compute_health_check" "this" {
  project            = var.vm_project
  name               = "https-health-check"
  check_interval_sec = 5
  timeout_sec        = 5

  https_health_check {
    port_name = "https"
  }
}

resource "google_compute_instance_group" "this" {
  name    = "elb-instance-group"
  project = var.vm_project
  network = data.google_compute_network.this.self_link
  zone    = data.google_compute_instance.this.zone
  named_port {
    name = "https"
    port = 443
  }
  instances = [data.google_compute_instance.this.self_link]
}

variable "subnetwork_name" {
  description = "The name of the subnetwork to use for the instance."
  type        = string

}

variable "vm_project" {
  description = "The project to create the instance in"
  type        = string

}

variable "vm_name" {
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


variable "vm_zone" {
  description = "The zone to create the instance in"
  type        = string

}
