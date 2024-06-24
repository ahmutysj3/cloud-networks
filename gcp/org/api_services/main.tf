data "google_projects" "this" {
  filter = "lifecycleState:ACTIVE"
}

locals {
  definition_file  = file("${path.module}/api_services.yml")
  project_services = { for k, v in yamldecode(local.definition_file).enable_apis : v.project => v }
  project_ids      = { for k, v in data.google_projects.this.projects : v.name => v.project_id }
}

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 15.0"

  for_each = local.project_services

  project_id                  = local.project_ids[each.value.project]
  enable_apis                 = true
  disable_services_on_destroy = true
  disable_dependent_services  = true

  activate_apis = each.value.services
}


