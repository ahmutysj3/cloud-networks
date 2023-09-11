terraform {
  backend "consul" {
    address = "consul-01.tracecloud.us:8500"
    scheme  = "http"
    lock    = true
    gzip    = false
    path    = "aws/vpc-peering/terraform.tfstate"
  }

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.19.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.13.0"
    }
  }

}