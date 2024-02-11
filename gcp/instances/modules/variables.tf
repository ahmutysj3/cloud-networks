variable "instance_name" {
  description = "The name of the instance"
  type        = string
}

variable "machine_type" {
  description = "The machine type to use"
  type        = string
}

variable "tags" {
  description = "The tags to apply to the instance"
  type        = list(string)
}

variable "network_project" {
  description = "The project where the network is located"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "subnetwork_name" {
  description = "The name of the subnetwork"
  type        = string
}

variable "gcp_region" {
  description = "The region to deploy the instance"
  type        = string
}

variable "allow_hc" {
  description = "Allow all hc traffic to the instance"
  type        = bool

}

variable "allow_all" {
  description = "Allow all traffic to the instance"
  type        = bool
}

