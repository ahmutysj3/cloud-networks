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
