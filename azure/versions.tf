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

/* provider "azurerm" {
  features {}
} */

provider "aws" {
  region = var.aws_region
}

locals {
  jim_az_profile = file("/home/trace/.azure/jimboProfile.json")
  jim_az_decoded = jsondecode(local.jim_az_profile)
  jim_az_provider_creds = {
    tenant_id     = local.jim_az_decoded.tenant
    client_id     = local.jim_az_decoded.appId
    client_secret = local.jim_az_decoded.password
  }
  jim_az_sub_id = chomp(file("/home/trace/.azure/jim_subscription"))


}

provider "azurerm" {
  subscription_id = local.jim_az_sub_id
  tenant_id       = local.jim_az_provider_creds.tenant_id
  client_id       = local.jim_az_provider_creds.client_id
  client_secret   = local.jim_az_provider_creds.client_secret

  features {}
}
