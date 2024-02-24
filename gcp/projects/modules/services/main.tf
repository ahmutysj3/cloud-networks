resource "google_project_service" "this" {
  for_each = toset(var.services)
  project  = var.project
  service  = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

