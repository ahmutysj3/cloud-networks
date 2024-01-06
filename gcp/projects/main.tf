data "google_projects" "this" {
  filter = "name:trace-* lifecycleState:ACTIVE"
}

locals {
  project_ids      = [for project in data.google_projects.this.projects : project.project_id]
  app_vpc_projects = [for project in local.project_ids : project if length(regexall("^trace-vpc-app-.*", project)) > 0]
}

module "edge_vpc_project" {
  source   = "./services"
  project  = var.edge_project
  services = var.edge_network_services
}

module "app_vpc_projects" {
  source   = "./services"
  for_each = toset(local.app_vpc_projects)
  project  = each.key
  services = var.app_network_services
}

module "vm_project" {
  source   = "./services"
  project  = var.vm_project
  services = var.vm_services
}
