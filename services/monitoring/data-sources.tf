#--------------------------------------------------------------
# Data Sources - External Dependencies
#--------------------------------------------------------------

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
data "terraform_remote_state" "sqs_processing" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.terraform_state_bucket
    key    = "global/sqs-processing/terraform.tfstate"
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
