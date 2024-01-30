variable "instance_name" {
  description = "The name of the instance"
  type        = string
}

variable "machine_type" {
  description = "The machine type to create"
  type        = string
}

variable "gcp_region" {
  description = "The region to create the instance in"
  type        = string
}

variable "tags" {
  description = "The tags to apply to the instance"
  type        = list(string)
}

variable "vm_project" {
  description = "The project to create the instance in"
  type        = string
}


variable "network_project" {
  description = "The project to create the instance in"
  type        = string

}
