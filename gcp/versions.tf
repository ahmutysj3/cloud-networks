terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.63.1"
    }
  }
  backend "consul" {
    address = "consul-01.tracecloud.us:8500"
    scheme  = "http"
    lock    = true
    gzip    = false
    path    = "gcp/peered-network/terraform.tfstate"
  }
}

provider "google" {
  credentials = file("~/.gcp/credentials/trace-gcp-tf.json")
  project     = var.gcp_project
  region      = var.gcp_region
}



