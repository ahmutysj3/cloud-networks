output "fortigate_initial_password" {
  value = random_string.initial_password.result
}

output "fw_mgmt_ip" {
  value = google_compute_address.fw_mgmt_external.address
}