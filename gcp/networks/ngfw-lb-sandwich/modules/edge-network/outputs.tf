output "subnet" {
  value = google_compute_subnetwork.this.self_link
}

output "network" {
  value = google_compute_network.this.name
}

output "ip_addr" {
  value = cidrhost(google_compute_subnetwork.this.ip_cidr_range, 2)
}

output "gateway" {
  value = google_compute_subnetwork.this.gateway_address
}
