variable "vpcs" {
  description = "builds the hub/spoke VPCs"
  type = map(object({
    cidr = string
    type = string
  }))
}

variable "spoke_subnets" {
  description = "used to build firewall subnets"
  type = map(object({
    vpc_id = string
    cidr   = string
    mgmt   = bool
  }))
}

