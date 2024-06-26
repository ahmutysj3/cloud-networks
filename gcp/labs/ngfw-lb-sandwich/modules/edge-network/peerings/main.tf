locals {
  peering_configs = {
    hub = {
      name : "${var.hub_vpc_name}-to-${var.spoke_vpc_name}-peering",
      network : var.hub_vpc_self_link,
      peer_network : var.spoke_vpc_self_link,
      import_custom_routes : false,
      export_custom_routes : true,
    },
    spoke = {
      name : "${var.spoke_vpc_name}-to-${var.hub_vpc_name}-peering",
      network : var.spoke_vpc_self_link,
      peer_network : var.hub_vpc_self_link,
      import_custom_routes : true,
      export_custom_routes : false,
    },
  }
}

resource "google_compute_network_peering" "this" {
  for_each = local.peering_configs

  name                                = each.value.name
  network                             = each.value.network
  peer_network                        = each.value.peer_network
  import_custom_routes                = each.value.import_custom_routes
  export_custom_routes                = each.value.export_custom_routes
  export_subnet_routes_with_public_ip = var.export_subnet_routes_with_public_ip
  stack_type                          = var.stack_type
}
