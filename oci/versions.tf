terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.98.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.39.0"
    }
  }
  backend "s3" {
    bucket = "trace-tf-unlocked-bucket"
    key    = "network/oci-terraform.tfstate"
    region = "us-east-1"
  }
}

provider "oci" {
}

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
  region                  = "us-east-1"
}



