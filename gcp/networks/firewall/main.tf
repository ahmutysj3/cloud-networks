resource "google_compute_firewall" "this" {
  for_each = { for k, v in var.firewall_rules : v.name => v }

  name               = each.value.name
  network            = each.value.network
  project            = each.value.project
  priority           = each.value.priority
  direction          = upper(each.value.direction)
  destination_ranges = each.value.destination_ranges
  source_ranges      = each.value.source_ranges
  target_tags        = each.value.target_tags
  source_tags        = each.value.source_tags

  dynamic "allow" {
    for_each = { for k, v in each.value.rules : k => v if each.value.action == "allow" }

    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = { for k, v in each.value.rules : k => v if each.value.action == "deny" }

    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
}

resource "google_compute_route" "this" {
  for_each = { for k, v in var.firewall_routes : v.name => v }

  name                   = each.value.name
  dest_range             = each.value.dest_range
  network                = each.value.network
  project                = each.value.project
  next_hop_ip            = each.value.next_hop_ip
  next_hop_gateway       = each.value.next_hop_gateway
  next_hop_ilb           = each.value.next_hop_ilb
  next_hop_instance      = each.value.next_hop_instance
  next_hop_instance_zone = each.value.next_hop_instance_zone
  next_hop_vpn_tunnel    = each.value.next_hop_vpn_tunnel
  priority               = each.value.priority
}
