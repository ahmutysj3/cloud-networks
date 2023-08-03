output "vcn_id" {
  value = merge({
    for k in oci_core_vcn.spoke :
    k.display_name => k.id
    },
    {
      "hub" = oci_core_vcn.hub.id
  })
}

output "vcn_cidr" {
  value = merge({
    for k in oci_core_vcn.spoke :
    k.display_name => k.cidr_block
    },
    {
      "hub" = oci_core_vcn.hub.cidr_block
  })
}

output "subnet_cidr" {
  value = merge({
    for k in oci_core_subnet.spoke :
    k.display_name => k.cidr_block
    },
    {
      for k in oci_core_subnet.hub :
      k.display_name => k.cidr_block
  })
}

output "subnet_id" {
  value = merge({ for k in oci_core_subnet.hub :
    k.display_name => k.id },
    {
      for k in oci_core_subnet.spoke :
      k.display_name => k.id
  })
}

output "lpg_id" {
  value = merge({ for k in oci_core_local_peering_gateway.hub :
    k.display_name => k.id },
    {
      for k in oci_core_local_peering_gateway.spoke :
      k.display_name => k.id
  })
}

output "hub_vcn_all_attributes" {
  description = "all attributes of created vcn"
  value       = { for k, v in oci_core_vcn.hub : k => v }
}

output "spoke_vcn_all_attributes" {
  description = "all attributes of created vcn"
  value       = { for k, v in oci_core_vcn.spoke : k => v }
}

output "net-compartment" {
  value = oci_identity_compartment.network.id
}