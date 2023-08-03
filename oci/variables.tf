variable "spoke_subnets" {
  type = map(object({
    cidr     = string
    private  = bool
    vcn      = string
    instance = string
  }))
}

variable "main_compartment" {
  type      = string
  sensitive = true
  default   = "ocid1.compartment.oc1..aaaaaaaat5rbfg2arowbqq5qodsvbcv6yn63e2ewljlhwgbpv4fegqc3hvdq"
}

variable "spoke_vcns" {
  type = map(object({
    cidr = string
  }))
}

variable "nsg_params" {
  type = map(object({
    rules = map(object({
      description = string
      source_type = string
      allow_from  = string
      ports = map(object({
        protocol = string
        min      = number
        max      = number
        type     = number
        code     = number
      }))
    }))
  }))
}

variable "nsg_vcn" {
  type = map(any)
}
