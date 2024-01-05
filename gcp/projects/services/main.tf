resource "google_project_service" "vpc_edge" {
  for_each = toset(var.services)
  project  = var.project
  service  = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}


variable "project" {
  type = string
}

variable "services" {
  type = list(string)
}

