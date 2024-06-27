variable "edge_project" {
  type        = string
  description = "The project id of the edge project"
  default     = ""
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
  default = []
}

variable "firewall_routes" {
  type = list(object({
    name                   = string
    dest_range             = string
    network                = string
    project                = string
    priority               = optional(number)
    target_tags            = optional(list(string))
    next_hop_gateway       = optional(string)
    next_hop_ip            = optional(string)
    next_hop_instance      = optional(string)
    next_hop_instance_zone = optional(string)
    next_hop_ilb           = optional(string)
    next_hop_vpn_tunnel    = optional(string)
  }))
  default = []
}
