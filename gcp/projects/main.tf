data "google_projects" "this" {
  filter = "name:trace-* lifecycleState:ACTIVE"
}

locals {
  project_ids = { for k, v in data.google_projects.this.projects : v.name => v.project_id }

  projects = {
    trace-vpc-app-prod = var.app_network_services
    trace-vpc-edge     = var.edge_network_services
    trace-vm-instance  = var.vm_services
    trace-gke-project  = var.vm_services
  }

  host_projects    = ["trace-vpc-app-prod"]
  service_projects = [local.project_ids["trace-vm-instance"], local.project_ids["trace-gke-project"]]
}

module "project_services" {
  source   = "./modules/services"
  for_each = local.projects
  project  = local.project_ids[each.key]
  services = each.value
}

module "shared_vpc" {
  source           = "./modules/shared_vpc"
  for_each         = toset(local.host_projects)
  host_project     = local.project_ids[each.key]
  service_projects = local.service_projects
}
