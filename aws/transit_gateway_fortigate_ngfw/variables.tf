variable "region_aws" {
  description = "AWS Region"
  type        = string
}

variable "firewall_defaults" {
  description = "default subnet and interface values for firewall"
  type = object({
    subnets       = list(string)
    rt_tables     = list(string)
    instance_type = string
  })
}

variable "transit_gateway_defaults" {
  description = "values for the transit gateway default option values"
  type = object({
    amazon_side_asn                 = number
    auto_accept_shared_attachments  = string
    default_route_table_association = string
    default_route_table_propagation = string
    multicast_support               = string
    dns_support                     = string
    vpn_ecmp_support                = string
  })
}

variable "network_prefix" {
  description = "prefix to prepend on all resource names within the network"
  type        = string
}

variable "supernet_cidr" {
  description = "cidr block for entire datacenter, must be /16"
  type        = string
}

variable "spoke_vpc_params" {
  description = "parameters for spoke VPCs"
  type = map(object({
    cidr_block = string
    subnets    = list(string)
  }))
}

variable "firewall_params" {
  description = "options for fortigate firewall instance"
  type = object({
    firewall_name            = string
    outside_extra_public_ips = number
    inside_extra_private_ips = number
  })
}

variable "cloud_watch_params" {
  description = "values for cloudwatch logging"
  type = object({
    cloud_watch_on    = bool
    retention_in_days = number
  })
}