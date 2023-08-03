resource "oci_identity_compartment" "network" {
  compartment_id = var.main_compartment
  description    = "Network Infrastructure Lab"
  name           = "network"
}

resource "oci_core_vcn" "hub" {
  compartment_id = oci_identity_compartment.network.id
  cidr_block     = var.hub_vcn_cidr
  display_name   = "${var.dc_name}_hub_vcn"
  dns_label      = "hubvcn"
}

resource "oci_core_vcn" "spoke" {
  for_each       = var.spoke_vcns
  compartment_id = oci_identity_compartment.network.id
  cidr_block     = each.value.cidr
  display_name   = "${var.dc_name}_${each.key}_vcn"
  dns_label      = each.key
}

resource "oci_core_local_peering_gateway" "hub" {
  for_each       = var.spoke_vcns
  compartment_id = oci_identity_compartment.network.id
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "${var.dc_name}_hub_lpg_to_${each.key}"
  peer_id        = oci_core_local_peering_gateway.spoke[each.key].id
}

resource "oci_core_local_peering_gateway" "spoke" {
  for_each       = var.spoke_vcns
  compartment_id = oci_identity_compartment.network.id
  vcn_id         = oci_core_vcn.spoke[each.key].id
  display_name   = "${var.dc_name}_hub_lpg_to_${each.key}_vcn"
}

resource "oci_core_internet_gateway" "hub" {
  compartment_id = oci_identity_compartment.network.id
  vcn_id         = oci_core_vcn.hub.id
  enabled        = var.internet_gateway_enabled
  display_name   = "${var.dc_name}_hub_igw"
}

resource "oci_core_subnet" "hub" {
  for_each                   = local.hub_subnets
  display_name               = "${var.dc_name}_${each.key}_subnet_pri"
  compartment_id             = oci_identity_compartment.network.id
  vcn_id                     = oci_core_vcn.hub.id
  cidr_block                 = each.value.cidr
  dns_label                  = each.key
  prohibit_public_ip_on_vnic = each.value.private
  security_list_ids          = [oci_core_security_list.hub[each.key].id]
  route_table_id             = oci_core_route_table.hub.id
}

resource "oci_core_subnet" "spoke" {
  for_each       = var.spoke_subnets
  display_name   = "${var.dc_name}_${each.key}_subnet_pri"
  compartment_id = oci_identity_compartment.network.id
  vcn_id         = oci_core_vcn.spoke[each.value.vcn].id
  cidr_block     = each.value.cidr
  dns_label      = each.key
  freeform_tags = {
    "instance" = "${each.value.instance}"
  }
  prohibit_public_ip_on_vnic = each.value.private
  route_table_id             = oci_core_route_table.spoke[each.value.vcn].id
}

resource "oci_core_route_table" "spoke" {
  for_each       = var.spoke_vcns
  compartment_id = oci_identity_compartment.network.id
  vcn_id         = oci_core_vcn.spoke[each.key].id
  display_name   = "${each.key}_main_rt"
  route_rules {
    network_entity_id = oci_core_local_peering_gateway.spoke[each.key].id
    description       = "Routes all ${each.key} traffic to the Hub VCN"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table" "hub_lpg" {
  depends_on = [
    oci_core_local_peering_gateway.hub
  ]
  compartment_id = oci_identity_compartment.network.id
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "${var.dc_name}_hub_lpg_rt"

  dynamic "route_rules" {
    for_each = var.spoke_vcns

    content {
      network_entity_id = oci_core_local_peering_gateway.hub[route_rules.key].id
      description       = "Routes ${route_rules.key} traffic to appropriate LPG"
      destination       = route_rules.value.cidr
      destination_type  = "CIDR_BLOCK"
    }
  }
}

resource "oci_core_route_table" "hub" {
  compartment_id = oci_identity_compartment.network.id
  vcn_id         = oci_core_vcn.hub.id
  display_name   = "${var.dc_name}_hub_main_rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.hub.id
    description       = "Routes all traffic to IGW"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_network_security_group" "spoke1" {
  for_each       = var.nsg_params
  compartment_id = oci_identity_compartment.network.id
  vcn_id         = oci_core_vcn.spoke["morty"].id
  display_name   = each.key
}


resource "oci_core_security_list" "hub" {
  compartment_id = oci_identity_compartment.network.id
  vcn_id         = oci_core_vcn.hub.id
  for_each       = local.hub_subnets
  display_name   = "${var.dc_name}_${each.key}_sl_pri"

  egress_security_rules { ## egress allow all 
    description = "Allows all egress traffic"
    stateless   = "false"
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" { ## allow inbound https from internet (fwmgmt subnet only)
    iterator = sub_sl
    for_each = {
      for subk, sub in local.hub_subnets : subk => sub if subk == each.key && length(regexall("fwmgmt", each.key)) == 1
    }

    content {
      description = "Allows all inbound https traffic"
      stateless   = "false"
      protocol    = "6"
      source      = "0.0.0.0/0"

      tcp_options {
        min = 443
        max = 443
      }
    }
  }

  dynamic "ingress_security_rules" { ## allow all inbound tcp/22 from internet (fwmgmt subnet only)
    iterator = sub_sl
    for_each = {
      for subk, sub in local.hub_subnets : subk => sub if subk == each.key && length(regexall("fwmgmt", each.key)) == 1
    }

    content {
      description = "Allows all inbound ssh/scp traffic"
      stateless   = "false"
      protocol    = "6"
      source      = "0.0.0.0/0"


      tcp_options {
        min = 22
        max = 22
      }
    }
  }


  dynamic "ingress_security_rules" { ## allow all inbound internet traffic from internet (fwoutside subnet only)
    iterator = sub_sl
    for_each = {
      for subk, sub in local.hub_subnets : subk => sub if subk == each.key && length(regexall("fwoutside", each.key)) == 1
    }

    content {
      description = "Allows all inbound traffic"
      stateless   = "false"
      protocol    = "all"
      source      = "0.0.0.0/0"
    }
  }

  dynamic "ingress_security_rules" { ## allow all inbound traffic from within supernet (fwinside subnet only)
    iterator = sub_sl
    for_each = {
      for subk, sub in local.hub_subnets : subk => sub if subk == each.key && length(regexall("fwinside", each.key)) == 1
    }

    content {
      description = "Allows all inbound traffic from within ${var.dc_name} datacenter"
      stateless   = "false"
      protocol    = "all"
      source      = var.supernet_cidr
    }
  }


  dynamic "ingress_security_rules" { # allow all ICMP type 1 from internet (Applies only to fwmgmt subnet)
    iterator = sub_sl
    for_each = {
      for subk, sub in local.hub_subnets : subk => sub if subk == each.key && length(regexall("fwmgmt", each.key)) == 1
    }
    content {
      description = "Allows ICMP from internet"
      stateless   = "true"
      protocol    = "1"
      source      = "0.0.0.0/0"
    }
  }
}

locals {

  hub_subnets = {
    fwinside = {
      cidr    = "${cidrsubnet("${var.hub_vcn_cidr}", 4, 0)}"
      private = true
    }
    fwoutside = {
      cidr    = "${cidrsubnet("${var.hub_vcn_cidr}", 4, 1)}"
      private = false
    }
    fwmgmt = {
      cidr    = "${cidrsubnet("${var.hub_vcn_cidr}", 4, 2)}"
      private = false
    }
  }
}

