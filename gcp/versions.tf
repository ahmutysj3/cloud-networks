terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.63.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.35.0"
    }

  }
  backend "s3" {
    bucket = "trace-tf-unlocked-bucket"
    key    = "network/gcp-terraform.tfstate"
    region = "us-east-1"
  }
}

provider "google" {
  credentials = file("~/.gcp/credentials/trace-gcp-tf.json")
  project     = var.gcp_project
  region      = var.gcp_region
}

provider "aws" {
  region = var.aws_region
}

