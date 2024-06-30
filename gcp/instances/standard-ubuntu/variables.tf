variable "vm_project" {
  description = "The project to create the instance in"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "The region to create the instance in"
  type        = string
  default     = ""
}

variable "instances" {
  description = "The instances to create"
  type = list(object({
    name       = string
    vm_project = string
    image = object({
      name    = string
      project = string
    })
    tags         = list(string)
    machine_type = optional(string)
    zone         = optional(string)
    nic = object({
      subnet           = string
      vpc_project      = string
      assign_public_ip = bool
      address          = optional(string)
    })
  }))
  default = []
}
