variable "project" {
  description = "The project to create the instance in"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region to create the instance in"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "name of the vpc"
  type        = string
  default     = "test-vpc"
}

variable "subnet_name" {
  description = "name of the subnet"
  type        = string
  default     = "test-subnet"
}

variable "ip_cidr_range" {
  description = "ip cidr range"
  type        = string
  default     = "10.0.0.0/24"
}
