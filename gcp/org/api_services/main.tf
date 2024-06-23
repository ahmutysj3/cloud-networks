locals {
  vm_project_services   = { for k, v in toset(var.vm_services) : v => var.project_ids[var.project_names["vm"]] }
  edge_project_services = { for k, v in toset(var.edge_network_services) : v => var.project_ids[var.project_names["edge"]] }
  app_project_services  = { for k, v in toset(var.app_network_services) : v => var.project_ids[var.project_names["app_vpc"]] }
  gke_project_services  = { for k, v in toset(var.gke_project_services) : v => var.project_ids[var.project_names["gke"]] }
}

resource "google_compute_shared_vpc_host_project" "this" {
  provider = google-beta
  project  = var.host_project
}

resource "google_compute_shared_vpc_service_project" "this" {
  provider        = google-beta
  for_each        = toset(var.service_projects)
  service_project = each.key
  host_project    = google_compute_shared_vpc_host_project.this.project
}

resource "google_project_service" "vm" {
  for_each = local.vm_project_services
  project  = each.value
  service  = each.key

  timeouts {
    create = var.timeouts["create"]
    update = var.timeouts["update"]
  }

  disable_dependent_services = var.disable_dependent_services
}

resource "google_project_service" "edge" {
  for_each = local.edge_project_services
  project  = each.value
  service  = each.key

  timeouts {
    create = var.timeouts["create"]
    update = var.timeouts["update"]
  }

  disable_dependent_services = var.disable_dependent_services
}

resource "google_project_service" "app" {
  for_each = local.app_project_services
  project  = each.value
  service  = each.key

  timeouts {
    create = var.timeouts["create"]
    update = var.timeouts["update"]
  }

  disable_dependent_services = var.disable_dependent_services
}

resource "google_project_service" "gke" {
  for_each = local.gke_project_services
  project  = each.value
  service  = each.key

  timeouts {
    create = var.timeouts["create"]
    update = var.timeouts["update"]
  }

  disable_dependent_services = var.disable_dependent_services
}



