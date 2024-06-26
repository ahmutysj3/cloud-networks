variable "ip_block" {
  type = string
}

variable "router" {
  type = bool
}

variable "vpc" {
  type = string
}

variable "spoke_vpcs" {
  type = map(string)
}

variable "nat_ip_allocate_option" {
  type    = string
  default = "AUTO_ONLY"
}

variable "source_subnetwork_ip_ranges_to_nat" {
  type    = string
  default = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "log_config" {
  type = map(string)
  default = {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
