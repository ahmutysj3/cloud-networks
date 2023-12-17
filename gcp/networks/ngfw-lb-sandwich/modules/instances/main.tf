resource "google_compute_instance" "this" {
  count        = length(var.web_subnets)
  name         = "web-server-instance-${count.index}"
  project      = var.gcp_project
  provider     = google
  machine_type = "e2-small"
  zone         = data.google_compute_zones.available.names[0]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata = {
    ssh-keys = "trace:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjI2kHRd2kAMmb8wbVmu66q/MfHhGiop6tZ1s7e9iJ+TzOK0S92cfIxrBTu08J6MhTg/CUfZwHe6WKB3sA5A2tWOLLpYdkvvwAojOh0z7hD9l8UZ57agRu0aaVfOofQwhQBWZFiOWIOUWmLAtHCxejV24ICJt/+pk1D+0MhqulKccC1Si7RZgzBqGzeH64mwgTbbl/QD3Hf2NcT5PvUZL9yWJDonoh1CZ5j4SfU/YJBBQXXsI3LJkH5gGCz2+CY+ZhZbtnCLrDMsgzK9uUSamdZ7bIiBi0LAM8P9O+QK75kBwnyRvQly92sIP50uxMGAfI8D/MfmHoP9pcTmHFbWcv trace@trace-laptop"

  }

  network_interface {
    network    = var.vpcs["prod-app"].id
    subnetwork = data.google_compute_subnetwork.this[count.index].id
  }

  metadata_startup_script = <<-EOF1
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

      cat <<EOF > /var/www/html/index.html
      <pre>
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF
    EOF1


}

data "google_compute_subnetwork" "this" {
  count   = length(var.web_subnets)
  name    = "web-subnet-${count.index}"
  region  = var.gcp_region
  project = var.gcp_project
}

output "web_subnets" {
  value = data.google_compute_subnetwork.this
}

data "google_compute_zones" "available" {
  region = var.gcp_region
}
