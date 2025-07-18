terraform {
  required_version = ">= 1.12"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.98"
    }
  }

  backend "s3" {
    bucket = "vclipper-terraform-state-dev-rmxhnjty"
    region = "us-east-1"
    key    = "global/app-infra/terraform.tfstate"
  }
}

provider "aws" {
  region = data.terraform_remote_state.global.outputs.aws_region
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = data.terraform_remote_state.global.outputs.project_name
      Service     = "app-infra"
      Environment = var.environment
    }
  }
}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.terraform_state_bucket
    key    = "global/terraform.tfstate"
  }
}
