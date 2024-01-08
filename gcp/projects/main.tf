data "google_projects" "this" {
  filter = "name:trace-* lifecycleState:ACTIVE"
}

locals {
  project_ids      = [for project in data.google_projects.this.projects : project.project_id]
  app_vpc_projects = [for project in local.project_ids : project if length(regexall("^trace-vpc-app-.*", project)) > 0]
  edge_project     = [for project in local.project_ids : project if length(regexall(var.edge_project, project)) > 0]
  vm_projects      = [for project in local.project_ids : project if length(regexall("^trace-vm-instance*", project)) > 0]
}

module "edge_vpc_project" {
  for_each = toset(local.edge_project)
  source   = "./modules/services"
  project  = each.key
  services = var.edge_network_services
}

module "app_vpc_projects" {
  source   = "./modules/services"
  for_each = toset(local.app_vpc_projects)
  project  = each.key
  services = var.app_network_services
}

module "vm_project" {
  for_each = toset(local.vm_projects)
  source   = "./modules/services"
  project  = each.key
  services = var.vm_services
}

module "shared_vpc" {
  source           = "./modules/shared_vpc"
  for_each         = toset(local.app_vpc_projects)
  host_project     = each.key
  service_projects = local.vm_projects
}
