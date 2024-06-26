output "fw_networks" {
  value = {
    for k, v in google_compute_network.this : k => {
      name      = v.name
      self_link = v.self_link
  } }
}

output "fw_subnets" {
  value = {
    for k, v in google_compute_subnetwork.this : k => {
      name      = v.name
      self_link = v.self_link
      cidr      = v.ip_cidr_range
      gateway   = v.gateway_address
    }
  }
}
