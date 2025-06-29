#--------------------------------------------------------------
# VClipper Global Configuration
# This configuration provides shared values for all services
#--------------------------------------------------------------

# Get current AWS account ID and region
#data "aws_caller_identity" "current" {}
#data "aws_region" "current" {}

# Local values for consistent naming
locals {
  project_name  = "vclipper"
  environment   = "prod"
  aws_region    = "us-east-1"
  createdby     = "Hackaton VClipper Team"
  version_eks   = "1.33"
  instance_node = "t3.medium"
  volume_type   = "gp3"
  volume_size   = "30"
  mongodb_provider_name = "TENANT"
  mongodb_backing_provider_name = "AWS"
  mongodb_instance_size = "M0"
  name_prefix = "${local.project_name}-${local.environment}"
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}
