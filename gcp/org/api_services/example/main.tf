data "google_projects" "this" {
  filter = "name:trace-* lifecycleState:ACTIVE"
}

/* locals {
  project_ids = { for k, v in data.google_projects.this.projects : v.name => v.project_id }

  host_project     = local.project_ids[var.project_names["app_vpc"]]
  service_projects = [local.project_ids[var.project_names["vm"]], local.project_ids[var.project_names["gke"]]]

} */

/* module "org_projects" {
  source                = "../"
  project_names         = var.project_names
  project_ids           = local.project_ids
  host_project          = local.host_project
  service_projects      = local.service_projects
  vm_services           = var.vm_services
  edge_network_services = var.edge_network_services
  app_network_services  = var.app_network_services
  gke_project_services  = var.gke_project_services
} */
