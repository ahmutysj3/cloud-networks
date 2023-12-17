output "subnets" {
  value = merge(local.hub_subnets, local.protected_web)
}

output "web_subnets" {
  value = { for subnets, subnet in google_compute_subnetwork.web : subnet.name => subnet.id }
}

output "vpcs" {
  value = google_compute_network.this
}

output "vpc_prod_app_cidr_range" {
  value = local.vpcs.protected
}

locals {
  hub_subnets = {
    for k, v in google_compute_subnetwork.hub : v.name => v
  }
  protected_web = { for k, v in google_compute_subnetwork.web : v.name => v }
}
