resource "google_certificate_manager_certificate" "this" {
  name        = "ssl-cert"
  description = "The default cert"
  scope       = "DEFAULT"
  project     = var.vm_project
  managed {
    domains            = [var.domain]
    dns_authorizations = [google_certificate_manager_dns_authorization.this.id]
  }
}

resource "google_certificate_manager_certificate_map_entry" "this" {
  name         = "ssl-cert-map-entry"
  map          = google_certificate_manager_certificate_map.this.name
  hostname     = var.domain
  certificates = [google_certificate_manager_certificate.this.id]
}

resource "google_certificate_manager_certificate_map" "this" {
  name    = "ssl-cert-map"
  project = var.vm_project
}

data "cloudflare_zones" "this" {
  filter {
    name = "tracecloud.us"
  }
}

data "cloudflare_zone" "this" {
  zone_id = data.cloudflare_zones.this.zones[0].id
}

resource "cloudflare_record" "cname" {
  name    = google_certificate_manager_dns_authorization.this.dns_resource_record.0.name
  zone_id = data.cloudflare_zone.this.id
  type    = google_certificate_manager_dns_authorization.this.dns_resource_record.0.type
  value   = google_certificate_manager_dns_authorization.this.dns_resource_record.0.data
}

resource "cloudflare_record" "a" {
  name    = var.domain
  zone_id = data.cloudflare_zone.this.id
  type    = "A"
  value   = google_compute_global_address.this.address
}

variable "domain" {
  type = string
}


resource "google_certificate_manager_dns_authorization" "this" {
  name    = "${replace(var.domain, ".", "-")}-dns-auth"
  domain  = var.domain
  project = var.vm_project
}

output "record_name_to_insert" {
  value = google_certificate_manager_dns_authorization.this.dns_resource_record.0.name
}

output "record_type_to_insert" {
  value = google_certificate_manager_dns_authorization.this.dns_resource_record.0.type
}

output "record_data_to_insert" {
  value = google_certificate_manager_dns_authorization.this.dns_resource_record.0.data
}
