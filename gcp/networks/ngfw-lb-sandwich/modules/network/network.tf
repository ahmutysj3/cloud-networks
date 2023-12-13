resource "google_compute_network" "this" {
  for_each                        = local.vpcs
  project                         = var.gcp_project
  name                            = each.key
  auto_create_subnetworks         = false
  delete_default_routes_on_create = each.key == "untrusted" ? false : true
}

locals {
  vpc_peering = {
    trusted   = google_compute_network.this["protected"],
    protected = google_compute_network.this["trusted"]
  }
}

resource "google_compute_network_peering" "this" {
  for_each             = local.vpc_peering
  name                 = "${each.key}-to-${each.value.name}-peering"
  network              = google_compute_network.this[each.key].self_link
  peer_network         = each.value.self_link
  import_custom_routes = each.key == "protected" ? true : false
  export_custom_routes = each.key == "trusted" ? true : false
}

resource "google_compute_route" "this" {
  count       = var.default_fw_route ? 1 : 0
  name        = "default-fw-route"
  network     = google_compute_network.this["trusted"].name
  dest_range  = "0.0.0.0/0"
  next_hop_ip = cidrhost(google_compute_subnetwork.hub["trusted"].ip_cidr_range, 2)
}

resource "google_compute_instance_from_machine_image" "pfsense" {
  depends_on           = [google_compute_subnetwork.hub]
  count                = var.deploy_pfsense ? 1 : 0
  provider             = google-beta
  zone                 = data.google_compute_zones.available.names[0]
  name                 = var.pfsense_name
  source_machine_image = "projects/${var.gcp_project}/global/machineImages/${var.pfsense_machine_image}"
}

resource "google_compute_forwarding_rule" "this" {
  count                 = var.ilb_next_hop ? 1 : 0
  provider              = google-beta
  name                  = "fw-ilb-forwarding-rule"
  region                = var.gcp_region
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
  region              = var.gcp_region
  check_interval_sec  = 3
  timeout_sec         = 2
  unhealthy_threshold = 3
  tcp_health_check {
    port = 443
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
  region                = var.gcp_region
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
  region = var.gcp_region
}

resource "google_compute_subnetwork" "hub" {
  for_each      = { for k, v in local.vpcs : k => v if k != "protected" }
  project       = var.gcp_project
  name          = "${each.key}-subnet"
  ip_cidr_range = each.value
  region        = var.gcp_region
  network       = google_compute_network.this[each.key].name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

resource "google_compute_subnetwork" "web" {
  count         = length(var.web_subnets)
  project       = var.gcp_project
  name          = "web-subnet-${count.index}"
  ip_cidr_range = cidrsubnet(local.vpcs.protected, 8, count.index)
  region        = var.gcp_region
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
  network       = google_compute_network.this["protected"].name
}

locals {
  vpcs = {
    protected = "192.168.0.0/16"
    untrusted = "10.255.0.0/24"
    trusted   = "10.0.0.0/24"
  }
}
