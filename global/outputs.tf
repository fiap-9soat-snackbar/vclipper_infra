output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "common_tags" {
  description = "Common tags for all resources"
  value       = local.common_tags
}

output "name_prefix" {
  description = "Common name prefix for resources"
  value       = local.name_prefix
}

output "terraform_state_bucket" {
  description = "Name of the S3 bucket storing Terraform state"
  value       = "vclipper-terraform-state-dev-rmxhnjty"
}
