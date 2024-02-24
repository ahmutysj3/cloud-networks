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
