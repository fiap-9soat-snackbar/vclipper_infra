provider "aws" {
  region = data.terraform_remote_state.global.outputs.aws_region
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = data.terraform_remote_state.global.outputs.project_name
      Service     = "sqs-vclipper"
      Environment = data.terraform_remote_state.global.outputs.environment
    }
  }
}

terraform {
  #required_version = ">= 1.12"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = ">= 5.98"
    }
  }

  backend "s3" {
    region = "us-east-1"
    key    = "global/sqs/terraform.tfstate"
  }
}



data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "global/terraform.tfstate"
  }
}

#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get video storage bucket information
data "terraform_remote_state" "video_storage" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "global/video-storage/terraform.tfstate"
  }
}
