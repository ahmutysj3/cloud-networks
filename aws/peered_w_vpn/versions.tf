terraform {

  backend "s3" {
    bucket = "trace-tf-unlocked-bucket"
    key    = "aws/vpc/peered-w-vpn/terraform.tfstate"
    region = "us-east-1"
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