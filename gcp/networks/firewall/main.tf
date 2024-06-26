/* resource "google_compute_route" "default" {
  name        = "network-route"
  dest_range  = "15.0.0.0/24"
  network     = google_compute_network.default.name
  next_hop_ip = "10.132.1.5"
  priority    = 100
} */

data "google_projects" "this" {
  filter = "name:trace-vpc-* lifecycleState:ACTIVE"
}

data "google_compute_networks" "this" {
  for_each = local.shared_vpc_projects
  project  = each.value.project_id
}

locals {
  shared_vpc_projects = { for k, v in data.google_projects.this.projects : v.name => v if v.project_id != var.edge_project }
  shared_vpcs         = flatten([for k, v in data.google_compute_networks.this : v.networks])
}
