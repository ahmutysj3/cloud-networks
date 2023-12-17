output "subnets" {
  value = merge(local.hub_subnets, local.prod-app_web)
}

output "vpcs" {
  value = google_compute_network.this
}

output "vpc_prod_app_cidr_range" {
  value = local.vpcs.prod-app
}

locals {
  hub_subnets = {
    for k, v in google_compute_subnetwork.hub : v.name => v
  }
  prod-app_web = { for k, v in google_compute_subnetwork.web : v.name => v }
}
