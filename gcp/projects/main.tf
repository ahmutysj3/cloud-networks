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

  host_projects    = ["trace-vpc-app-prod", "trace-vpc-edge"]
  service_projects = ["trace-vm-instance", "trace-gke-project"]
}

moved {
  from = module.app_vpc_projects["trace-vpc-app-prod-410520"].google_project_service.this["compute.googleapis.com"]
  to   = module.project_services["trace-vpc-app-prod"].google_project_service.this["compute.googleapis.com"]
}

moved {
  from = module.edge_vpc_project["trace-vpc-edge"].google_project_service.this["compute.googleapis.com"]
  to   = module.project_services["trace-vpc-edge"].google_project_service.this["compute.googleapis.com"]
}

moved {
  from = module.vm_project["trace-vm-instance-410520"].google_project_service.this["certificatemanager.googleapis.com"]
  to   = module.project_services["trace-vm-instance"].google_project_service.this["certificatemanager.googleapis.com"]
}

moved {
  from = module.shared_vpc["trace-vpc-app-prod-410520"].google_compute_shared_vpc_host_project.this
  to   = module.shared_vpc["trace-vpc-app-prod"].google_compute_shared_vpc_host_project.this
}

moved {
  from = module.shared_vpc["trace-vpc-app-prod-410520"].google_compute_shared_vpc_service_project.this["trace-vm-instance-410520"]
  to   = module.shared_vpc["trace-vpc-app-prod"].google_compute_shared_vpc_service_project.this["trace-vm-instance"]
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
