terraform {
  backend "s3" {
    region = "us-east-1"
    key    = "database/atlas/mongodb/terraform.tfstate"
  }
  
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.0"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.mongodbatlas_org_public_key
  private_key = var.mongodbatlas_org_private_key
}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "global/terraform.tfstate"
  }
}

locals {
  databases = ["vclipper_processing", "vclipper_fe", "vclipping", "vclipper_user"]
}