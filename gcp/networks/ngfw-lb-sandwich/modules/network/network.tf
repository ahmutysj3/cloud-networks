locals {
  vpc_peering = {
    app-dev = {
      spoke = google_compute_network.this["app-dev"].self_link,
      hub   = google_compute_network.this["trusted"].self_link
    }
    app-prod = {
      spoke = google_compute_network.this["app-prod"].self_link,
      hub   = google_compute_network.this["trusted"].self_link
    }
  }
}

resource "google_compute_network" "this" {
  for_each                        = var.vpcs
  project                         = each.value.project
  name                            = each.key
  auto_create_subnetworks         = false
  delete_default_routes_on_create = each.key == "app-dev" || "app-prod" ? false : true
}

resource "google_compute_network_peering" "this" {
  for_each                            = local.vpc_peering
  name                                = "${each.key}-to-trusted-peering"
  network                             = each.value.hub
  peer_network                        = each.value.spoke
  import_custom_routes                = true
  export_custom_routes                = true
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_route" "this" {
  count       = var.default_fw_route ? 1 : 0
  project     = google_compute_network.this["trusted"].project
  name        = "default-fw-route"
  network     = google_compute_network.this["trusted"].name
  dest_range  = "0.0.0.0/0"
  next_hop_ip = cidrhost(google_compute_subnetwork.hub["trusted"].ip_cidr_range, 2)
}

resource "google_compute_firewall" "ingress" {
  for_each      = var.vpcs
  name          = "default-allow-all-ingress-${each.key}"
  project       = each.value.project
  network       = google_compute_network.this[each.key].name
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "egress" {
  for_each           = var.vpcs
  name               = "default-allow-all-egress-${each.key}"
  project            = each.value.project
  network            = google_compute_network.this[each.key].name
  priority           = 1000
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

resource "google_compute_instance_from_machine_image" "pfsense" {
  depends_on           = [google_compute_subnetwork.hub]
  count                = var.deploy_pfsense ? 1 : 0
  provider             = google-beta
  zone                 = var.zones[0]
  name                 = var.pfsense_name
  source_machine_image = "projects/${var.image_project}/global/machineImages/${var.pfsense_machine_image}"
}

resource "google_compute_forwarding_rule" "this" {
  count                 = var.ilb_next_hop ? 1 : 0
  provider              = google-beta
  name                  = "fw-ilb-forwarding-rule"
  region                = google_compute_network.this["trusted"].region
  ip_protocol           = "L3_DEFAULT"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  backend_service       = google_compute_region_backend_service.this[0].self_link
  network               = google_compute_network.this["trusted"].self_link
  subnetwork            = google_compute_subnetwork.hub["trusted"].self_link
  ip_address            = cidrhost(google_compute_subnetwork.hub["trusted"].ip_cidr_range, 252)
}

resource "google_compute_region_health_check" "this" {
  count               = var.ilb_next_hop ? 1 : 0
  name                = "fw-ilb-hc"
  region              = google_compute_network.this["trusted"].region
  check_interval_sec  = 3
  timeout_sec         = 2
  unhealthy_threshold = 3
  tcp_health_check {
    port = var.hc_port
  }
}

resource "google_compute_instance_group" "this" {
  count     = var.ilb_next_hop ? 1 : 0
  name      = "fw-ilb-instance-group"
  zone      = var.zones[0]
  instances = [google_compute_instance_from_machine_image.pfsense[0].self_link]

}
resource "google_compute_region_backend_service" "this" {
  count                 = var.ilb_next_hop ? 1 : 0
  name                  = "fw-ilb-backend-service"
  region                = google_compute_network.this["trusted"].region
  network               = google_compute_network.this["trusted"].self_link
  session_affinity      = "CLIENT_IP"
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.this[0].id]

  backend {
    group = google_compute_instance_group.this[0].self_link
  }
}



module "spoke_subnets" {
  source      = "./subnets"
  count       = { for k, v in var.vpcs : k => v if length(regexall("app-*", k)) > 0 }
  project     = google_compute_network.this[each.key].project
  region      = google_compute_network.this[each.key].region
  network     = google_compute_network.this[each.key].name
  web_subnets = var.web_subnets
  vpc         = each.key
  ip_block    = var.vpcs[each.key].cidr
}

