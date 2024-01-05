variable "edge_project" {
  type = string
}

variable "prod_project" {
  type = string
}

variable "bu1_project" {
  type = string
}

variable "bu2_project" {
  type = string
}

variable "dev_project" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "deploy_fortigate" {
  type = bool
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
