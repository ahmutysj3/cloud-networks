/* 
####
resource "google_compute_forwarding_rule" "this" {
  depends_on            = [module.backend_service]
  for_each              = local.fwd_rules
  name                  = "${var.name_prefix}-${each.key}-fwd-rule"
  region                = var.region
  project               = var.project
  load_balancing_scheme = "INTERNAL"
  ip_version            = google_compute_address.fwd_rule[each.key].ip_version
  ip_address            = google_compute_address.fwd_rule[each.key].address
  ip_protocol           = upper(var.protocol)
  subnetwork            = google_compute_address.fwd_rule[each.key].subnetwork
  backend_service       = module.backend_service.backend_service.self_link
  forward_all_ports             = var.forward_all_ports
  ports                 = var.forward_all_ports ? null : [each.value.ports]
}

locals {
  fwd_rule_ports = { for k, v in local.fwd_rules : k => v.ports }
}

resource "google_compute_address" "fwd_rule" {
  for_each     = local.fwd_rules
  address_type = "INTERNAL"
  name         = "${each.key}-fwd-ip"
  ip_version   = "IPV4"
  project      = var.project
  region       = var.region
  address      = each.value.ip_address
  subnetwork   = data.google_compute_subnetwork.this[each.key].self_link
}

data "google_compute_subnetwork" "this" {
  for_each = local.fwd_rules
  project  = var.project
  region   = var.region
  name     = each.value.subnet
}
 */
