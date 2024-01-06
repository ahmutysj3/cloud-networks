variable "edge_project" {
  type = string
}

variable "prod_vpc_project" {
  type = string
}

variable "dev_vpc_project" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "spoke_vpcs" {
  type = map(any)
}

variable "edge_vpcs" {
  type = map(any)
}

variable "image_project" {
  type = string
}

variable "spoke_subnets" {
  type = list(string)
}
