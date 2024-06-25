data "google_organization" "this" {
  domain = var.gcp_domain
}


data "google_projects" "this" {
  filter = "lifecycleState:ACTIVE"
}

output "projects" {
  value = data.google_projects.this
}

resource "google_folder" "root" {
  for_each     = { for k, v in local.definitions["root_folders"] : v.name => v }
  display_name = each.value.name
  parent       = data.google_organization.this.id
}

resource "google_folder" "sub" {
  for_each     = { for k, v in local.definitions["subfolders"] : v.name => v }
  display_name = each.value.name
  parent       = google_folder.root[each.value.parent].id
}

resource "google_project" "this" {
  for_each        = { for k, v in local.definitions["projects"] : v.name => v }
  name            = each.value.name
  project_id      = each.value.name == var.gcp_perm_project ? var.gcp_perm_project : "${each.value.name}-01"
  org_id          = each.value.folder == null ? data.google_organization.this.org_id : null
  folder_id       = try(google_folder.sub[each.value.folder].id, google_folder.root[each.value.folder].id, each.value.folder)
  billing_account = data.google_billing_account.this.id
}

data "google_billing_account" "this" {
  display_name = var.gcp_billing_account
  open         = true
}

locals {
  definitions = yamldecode(file("${path.module}/projects.yml"))
}

resource "google_compute_shared_vpc_host_project" "this" {
  for_each = toset(local.definitions.shared_vpcs["host_projects"])

  project = google_project.this[each.value].project_id
}

resource "google_compute_shared_vpc_service_project" "this" {
  depends_on = [google_compute_shared_vpc_host_project.this]

  for_each = { for k, v in local.definitions.shared_vpcs["service_projects"] : k => v }

  host_project    = google_compute_shared_vpc_host_project.this[each.value.connect_to].project
  service_project = google_project.this[each.value.project].project_id
}

