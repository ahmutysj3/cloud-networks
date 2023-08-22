terraform {
  /* backend "s3" {
    bucket         = "trace-terraform-bucket"
    key            = "aws/network/peered-w-vpn/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_db"
  } */

  backend "consul" {
    address = "consul-01.tracecloud.us:8500"
    scheme  = "http"
    lock = true 
    gzip = false
    path = "aws/peered-w-vpn/terraform.tfstate"
  }

  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.19.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.13.0"
    }
  }

}