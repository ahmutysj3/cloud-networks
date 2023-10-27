data "google_compute_instance" "this" {
  for_each = toset(var.instances)
  project  = var.project
  zone     = var.zone
  name     = each.key
}

resource "google_compute_instance_group" "this" {
  name      = var.name
  zone      = var.zone
  project   = var.project
  network   = var.network
  instances = [for instance in data.google_compute_instance.this : instance.self_link]
}