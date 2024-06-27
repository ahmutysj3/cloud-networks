/* resource "google_compute_route" "default" {
  name        = "network-route"
  dest_range  = "15.0.0.0/24"
  network     = google_compute_network.default.name
  next_hop_ip = "10.132.1.5"
  priority    = 100
} */

data "google_projects" "this" {
  filter = "name:trace-vpc-* lifecycleState:ACTIVE"
}

data "google_compute_networks" "this" {
  for_each = local.shared_vpc_projects
  project  = each.value.project_id
}

locals {
  shared_vpc_projects = { for k, v in data.google_projects.this.projects : v.name => v if v.project_id != var.edge_project }
  shared_vpcs         = flatten([for k, v in data.google_compute_networks.this : v.networks])
}


resource "google_compute_firewall" "this" {
  for_each           = { for k, v in var.firewall_rules : v.name => v }
  name               = each.value.name
  network            = each.value.network
  project            = each.value.project
  priority           = each.value.priority
  direction          = upper(each.value.direction)
  destination_ranges = each.value.destination_ranges
  source_ranges      = each.value.source_ranges
  target_tags        = each.value.target_tags
  source_tags        = each.value.source_tags

  dynamic "allow" {
    for_each = { for k, v in each.value.rules : k => v if each.value.action == "allow" }

    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = { for k, v in each.value.rules : k => v if each.value.action == "deny" }

    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
}

variable "firewall_rules" {
  type = list(object({
    name      = string
    action    = string
    direction = string
    network   = string
    project   = string
    rules = list(object({
      protocol = string
      ports    = optional(list(string))
    }))
    destination_ranges = optional(list(string))
    source_ranges      = optional(list(string))
    priority           = number
    target_tags        = optional(list(string))
    source_tags        = optional(list(string))
  }))
  default = [
    {
      name      = "test-firewall-ssh-rule-1"
      network   = "trace-vpc-edge-mgmt"
      project   = "trace-vpc-edge-prod-01"
      priority  = 1000
      action    = "allow"
      direction = "ingress"
      rules = [{
        ports    = ["22"]
        protocol = "tcp"
        }
      ]
      source_ranges = ["0.0.0.0/0"]
    },
    {
      name      = "test-firewall-ping-rule-1"
      network   = "trace-vpc-edge-mgmt"
      project   = "trace-vpc-edge-prod-01"
      priority  = 1000
      action    = "allow"
      direction = "ingress"
      rules = [{
        protocol = "icmp"
        }
      ]
      source_ranges = ["0.0.0.0/0"]
  }]
}

variable "firewall_routes" {
  type = list(object({
    name                = string
    dest_range          = string
    network             = string
    project             = string
    priority            = optional(number)
    target_tags         = optional(list(string))
    next_hop_gateway    = optional(string)
    next_hop_ip         = optional(string)
    next_hop_instance   = optional(string)
    next_hop_ilb        = optional(string)
    next_hop_vpn_tunnel = optional(string)
  }))
  default = [
    {
      name             = "fw-mgmt-default-inet-route-01"
      dest_range       = "0.0.0.0/0"
      network          = "trace-vpc-edge-mgmt"
      project          = "trace-vpc-edge-prod-01"
      priority         = 0
      next_hop_gateway = "default-internet-gateway"
    },
    {
      name             = "fw-untrusted-default-inet-route-01"
      dest_range       = "0.0.0.0/0"
      network          = "trace-vpc-edge-untrusted"
      project          = "trace-vpc-edge-prod-01"
      priority         = 0
      next_hop_gateway = "default-internet-gateway"
  }]
}


resource "google_compute_route" "this" {
  for_each            = { for k, v in var.firewall_routes : v.name => v }
  name                = each.value.name
  dest_range          = each.value.dest_range
  network             = each.value.network
  project             = each.value.project
  next_hop_ip         = each.value.next_hop_ip
  next_hop_gateway    = each.value.next_hop_gateway
  next_hop_ilb        = each.value.next_hop_ilb
  next_hop_instance   = each.value.next_hop_instance
  next_hop_vpn_tunnel = each.value.next_hop_vpn_tunnel
  priority            = each.value.priority
}
