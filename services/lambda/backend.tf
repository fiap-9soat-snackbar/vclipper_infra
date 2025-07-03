terraform {
  backend "s3" {
    region = "us-east-1"
    key    = "functions/lambda/terraform.tfstate"
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