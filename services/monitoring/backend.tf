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
    key    = "global/monitoring/terraform.tfstate"
  }
}

provider "aws" {
  region = data.terraform_remote_state.global.outputs.aws_region
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = data.terraform_remote_state.global.outputs.project_name
      Service     = "monitoring"
      Environment = data.terraform_remote_state.global.outputs.environment
    }
  }
}

#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------

# Global settings for standardization
data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.terraform_state_bucket
    key    = "global/terraform.tfstate"
  }
}

# SNS topics for alarm actions
data "terraform_remote_state" "sns_notifications" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.terraform_state_bucket
    key    = "global/sns-notifications/terraform.tfstate"
  }
}

# SQS queues for monitoring
data "terraform_remote_state" "sqs" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.terraform_state_bucket
    key    = "global/sqs/terraform.tfstate"
  }
}

# S3 video storage bucket for monitoring
data "terraform_remote_state" "video_storage" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.terraform_state_bucket
    key    = "global/video-storage/terraform.tfstate"
  }
}

# S3 frontend hosting for monitoring
data "terraform_remote_state" "frontend_hosting" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.terraform_state_bucket
    key    = "global/frontend-hosting/terraform.tfstate"
  }
}

# Cognito for monitoring
data "terraform_remote_state" "cognito" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.terraform_state_bucket
    key    = "global/cognito/terraform.tfstate"
  }
}

# API Gateway for monitoring
data "terraform_remote_state" "api_gateway" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.terraform_state_bucket
    key    = "global/api-gateway/terraform.tfstate"
  }
}
