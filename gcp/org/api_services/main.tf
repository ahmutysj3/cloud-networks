
/* resource "google_project_service" "this" {
  for_each = {}
  project  = each.value
  service  = each.key

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}
 */


locals {
  definition_file  = file("${path.module}/api_services.yml")
  project_services = { for k, v in yamldecode(local.definition_file).enable_apis : v.project => v.services }
}
