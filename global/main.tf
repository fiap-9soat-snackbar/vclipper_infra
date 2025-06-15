#--------------------------------------------------------------
# VClipper Global Configuration
# This configuration provides shared values for all services
#--------------------------------------------------------------

terraform {
  required_version = ">= 1.12"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.98"
    }
  }

  backend "s3" {
    region = "us-east-1"
    key    = "global/terraform.tfstate"
    # bucket will be specified during terraform init
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = var.project_name
    }
  }
}

# Get current AWS account ID and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values for consistent naming
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  name_prefix = "${var.project_name}-${var.environment}"
}
