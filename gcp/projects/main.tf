data "google_projects" "this" {
  filter = "name:trace-* lifecycleState:ACTIVE"
}

locals {
  project_ids       = [for project in data.google_projects.this.projects : project.project_id]
  vm_projects       = [for project in local.project_ids : project if length(regexall("^trace-vm-.*", project)) > 0]
  app_vpc_projects  = [for project in local.project_ids : project if length(regexall("^trace-vpc-app-.*", project)) > 0]
  edge_vpc_projects = [for project in local.project_ids : project if length(regexall("^trace-vpc-edge-.*", project)) > 0]
}

module "edge_vpc_projects" {
  source   = "./services"
  for_each = toset(local.edge_vpc_projects)
  project  = each.key
  services = var.edge_network_services
}

module "app_vpc_projects" {
  source   = "./services"
  for_each = toset(local.app_vpc_projects)
  project  = each.key
  services = var.app_network_services
}

module "vm_projects" {
  source   = "./services"
  for_each = toset(local.vm_projects)
  project  = each.key
  services = var.vm_services
}
