terraform {
  #required_version = ">= 1.12"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = ">= 5.98"
    }
  }

  backend "s3" {
    bucket = "vclipper-terraform-state-dev-rmxhnjty"
    region = "us-east-1"
    key    = "global/sns-notifications/terraform.tfstate"
  }
}

provider "aws" {
  region = data.terraform_remote_state.global.outputs.aws_region
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = data.terraform_remote_state.global.outputs.project_name
      Service     = "sns-notifications"
      Environment = data.terraform_remote_state.global.outputs.environment
    }
  }
}

#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------

# Get current AWS account ID
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "global/terraform.tfstate"
  }
}

