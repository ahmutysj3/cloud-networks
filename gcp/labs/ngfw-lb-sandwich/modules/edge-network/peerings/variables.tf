variable "spoke_vpc_name" {
  type = string
}

variable "spoke_vpc_self_link" {
  type = string
}

variable "hub_vpc_name" {
  type = string
}

variable "hub_vpc_self_link" {
  type = string
}

variable "export_subnet_routes_with_public_ip" {
  type    = bool
  default = false
}

variable "stack_type" {
  type    = string
  default = "IPV4_ONLY"
}
