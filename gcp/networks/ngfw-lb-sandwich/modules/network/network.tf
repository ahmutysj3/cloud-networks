locals {
  vpc_peering = {
    trusted   = google_compute_network.this["protected"],
    protected = google_compute_network.this["trusted"]
  }

  vpcs = {
    protected = "192.168.0.0/16"
    untrusted = "10.255.0.0/24"
    trusted   = "10.0.0.0/24"
  }
}

resource "google_compute_network" "this" {
  for_each                        = local.vpcs
  project                         = var.project
  name                            = each.key
  auto_create_subnetworks         = false
  delete_default_routes_on_create = each.key == "untrusted" ? false : true
}

resource "google_compute_network_peering" "this" {
  for_each                            = local.vpc_peering
  name                                = "${each.key}-to-${each.value.name}-peering"
  network                             = google_compute_network.this[each.key].self_link
  peer_network                        = each.value.self_link
  import_custom_routes                = each.key == "protected" ? true : false
  export_custom_routes                = each.key == "trusted" ? true : false
  export_subnet_routes_with_public_ip = false
}

resource "google_compute_route" "this" {
  count       = var.default_fw_route ? 1 : 0
  name        = "default-fw-route"
  network     = google_compute_network.this["trusted"].name
  dest_range  = "0.0.0.0/0"
  next_hop_ip = cidrhost(google_compute_subnetwork.hub["trusted"].ip_cidr_range, 2)
}

resource "google_compute_firewall" "ingress" {
  for_each      = local.vpcs
  name          = "default-allow-all-ingress-${each.key}"
  project       = var.project
  network       = google_compute_network.this[each.key].name
  priority      = 1000
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "egress" {
  for_each           = local.vpcs
  name               = "default-allow-all-egress-${each.key}"
  project            = var.project
  network            = google_compute_network.this[each.key].name
  priority           = 1000
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "all"
  }
}

# Creates a Cloud Router for the untrusted network
resource "google_compute_router" "edge_ext" {
  name    = "trace-untrusted-cloud-router"
  region  = var.region
  project = var.project
  network = google_compute_network.this["untrusted"].name
}

# Creates a Cloud Router for the untrusted network
resource "google_compute_router_nat" "edge_ext" {
  name                               = "${google_compute_router.edge_ext.name}-nat"
  router                             = google_compute_router.edge_ext.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.hub["untrusted"].self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_instance_from_machine_image" "pfsense" {
  depends_on           = [google_compute_subnetwork.hub]
  count                = var.deploy_pfsense ? 1 : 0
  provider             = google-beta
  zone                 = data.google_compute_zones.available.names[0]
  name                 = var.pfsense_name
  source_machine_image = "projects/${var.project}/global/machineImages/${var.pfsense_machine_image}"
}

resource "google_compute_forwarding_rule" "this" {
  count                 = var.ilb_next_hop ? 1 : 0
  provider              = google-beta
  name                  = "fw-ilb-forwarding-rule"
  region                = var.region
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
  region              = var.region
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
  zone      = data.google_compute_zones.available.names[0]
  instances = [google_compute_instance_from_machine_image.pfsense[0].self_link]

}
resource "google_compute_region_backend_service" "this" {
  count                 = var.ilb_next_hop ? 1 : 0
  name                  = "fw-ilb-backend-service"
  region                = var.region
  network               = google_compute_network.this["trusted"].self_link
  session_affinity      = "CLIENT_IP"
  protocol              = "UNSPECIFIED"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.this[0].id]

  backend {
    group = google_compute_instance_group.this[0].self_link
  }
}

data "google_compute_zones" "available" {
  region = var.region
}

resource "google_compute_subnetwork" "hub" {
  for_each      = { for k, v in local.vpcs : k => v if k != "protected" }
  project       = var.project
  name          = "${each.key}-subnet"
  ip_cidr_range = each.value
  region        = var.region
  network       = google_compute_network.this[each.key].name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

resource "google_compute_subnetwork" "web" {
  count         = length(var.web_subnets)
  project       = var.project
  name          = "${var.web_subnets[count.index]}-web-subnet"
  ip_cidr_range = cidrsubnet(local.vpcs.protected, 8, count.index)
  region        = var.region
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
  network       = google_compute_network.this["protected"].name
}

resource "google_compute_subnetwork" "proxy" {
  project       = var.project
  name          = "protected-proxy-subnet"
  ip_cidr_range = cidrsubnet(local.vpcs.protected, 8, 255)
  region        = var.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  network       = google_compute_network.this["protected"].name
  role          = "ACTIVE"
}

resource "google_compute_subnetwork" "ilb" {
  name          = "ilb-subnet"
  project       = var.project
  ip_cidr_range = cidrsubnet(local.vpcs.protected, 8, 100)
  region        = var.region
  network       = google_compute_network.this["protected"].name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}
