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
