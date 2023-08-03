variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "gcp_project" {
  type    = string
  default = "trace-tf-project"
}

variable "gcp_region" {
  type    = string
  default = "us-east1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "subnet_params" {
  type = map(object({
    cidr         = string
    vpc          = string
  }))
}

variable "vpc_params" {
  type = map(object({
    default_routes          = bool
    make_this_hub_vpc       = bool
  }))
}