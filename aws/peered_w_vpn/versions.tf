terraform {
  required_version = ">= 0.13.1"

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

  backend "s3" {
    bucket = "trace-tf-unlocked-bucket"
    key    = "main/vpc/vpn/terraform.tfstate"
    region = "us-east-1"
  }
}