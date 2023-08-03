terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.36.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.35.0"
    }
  }

  backend "s3" {
    bucket = "trace-tf-unlocked-bucket"
    key    = "network/azure-terraform.tfstate"
    region = "us-east-1"
  }
}  

provider "azurerm" {
  features {}
}

provider "aws" {
  region = var.aws_region
}