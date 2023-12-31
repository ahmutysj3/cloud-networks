terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
  /*   backend "consul" {
    address = "consul-01.tracecloud.us:8500"
    scheme  = "http"
    lock    = true
    gzip    = false
    path    = "gcp/peered-network/terraform.tfstate"
  } */


  backend "local" {
    path = "./terraform.tfstate"
  }


}




