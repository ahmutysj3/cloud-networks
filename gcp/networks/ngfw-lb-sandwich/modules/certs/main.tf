
data "google_secret_manager_secrets" "this" {
}

data "google_secret_manager_secret_version" "this" {
  for_each = toset([for each in data.google_secret_manager_secrets.this.secrets : each.secret_id])
  secret   = each.key
}

variable "root_domain" {
  type    = string
  default = "tracecloud"
}

locals {
  ssl_certificates = {
    for cert, value in data.google_secret_manager_secret_version.this : split("-${var.root_domain}-cert", cert)[0] => value.secret_data if length(regexall("-cert", value.name)) > 0
  }
  ssl_private_keys = {
    for key, value in data.google_secret_manager_secret_version.this : split("-${var.root_domain}-key", key)[0] => value.secret_data if length(regexall("-key", value.name)) > 0
  }
}

resource "google_compute_ssl_certificate" "this" {
  for_each    = local.ssl_certificates
  name        = "${each.key}-cert"
  private_key = local.ssl_private_keys[each.key]
  certificate = each.value

}
