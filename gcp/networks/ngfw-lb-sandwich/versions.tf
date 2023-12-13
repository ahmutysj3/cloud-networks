terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.9"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
  /*   backend "consul" {
    address = "consul-01.tracecloud.us:8500"
    scheme  = "http"
    lock    = true
    gzip    = false
    path    = "gcp/peered-network/terraform.tfstate"
  } */




}



