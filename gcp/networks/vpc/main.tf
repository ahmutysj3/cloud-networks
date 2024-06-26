locals {
  vpcs_definition_file = file("${path.module}/vpcs.yml")
  vpcs_definition      = yamldecode(local.vpcs_definition_file)
  vpcs                 = { for k, v in local.vpcs_definition["vpcs"] : v.name => v }

  flattened_subnets = flatten([
    for vpc in local.vpcs : [
      for subnet in vpc.subnets : {
        vpc_name   = vpc.name
        project    = vpc.project
        name       = subnet.name
        region     = subnet.region
        cidr_range = subnet.cidr_range
        purpose    = lookup(subnet, "purpose", null)
      }
    ]
  ])
  subnets = { for index, subnet in local.flattened_subnets : subnet.name => subnet }

  peerings_map = { for k, v in local.vpcs_definition["peerings"] : k => v }
  vpc_peerings = flatten([
    for peering in local.peerings_map : [
      {
        vpc          = peering.vpc
        peer         = peering.peer
        name         = "${peering.vpc}-to-${peering.peer}-peering"
        network      = google_compute_network.this[peering.vpc].self_link
        peer_network = google_compute_network.this[peering.peer].self_link
      },
      {
        vpc          = peering.peer
        peer         = peering.vpc
        name         = "${peering.peer}-to-${peering.vpc}-peering"
        network      = google_compute_network.this[peering.peer].self_link
        peer_network = google_compute_network.this[peering.vpc].self_link
      }
    ]
  ])
}

resource "google_compute_network" "this" {
  for_each = local.vpcs

  name                            = each.value.name
  project                         = each.value.project
  auto_create_subnetworks         = var.default_network_params.auto_create_subnetworks
  routing_mode                    = var.default_network_params.routing_mode
  delete_default_routes_on_create = var.default_network_params.delete_default_routes_on_create
}

resource "google_compute_subnetwork" "this" {
  for_each = local.subnets

  name          = each.value.name
  project       = each.value.project
  ip_cidr_range = each.value.cidr_range
  region        = each.value.region
  network       = google_compute_network.this[each.value.vpc_name].self_link
  purpose       = each.value.purpose
}

resource "google_compute_network_peering" "this" {
  for_each = { for p in local.vpc_peerings : p.name => p }

  name         = each.value.name
  network      = each.value.network
  peer_network = each.value.peer_network
}

