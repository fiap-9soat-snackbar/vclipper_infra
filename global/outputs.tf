# GLOBAL

output "project_name" {
  value = local.project_name
}

output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "aws_region" {
  value = local.aws_region
}

output "created_by" {
  value = local.createdby
}

output "version_eks" {
  value = local.version_eks
}

output "instance_node" {
  value = local.instance_node
}

output "volume_type" {
  value = local.volume_type
}

output "volume_size" {
  value = local.volume_size
}

output "mongodb_provider_name" {
  value = local.mongodb_provider_name
}

output "mongodb_backing_provider_name" {
  value = local.mongodb_backing_provider_name
}

output "mongodb_instance_size" {
  value = local.mongodb_instance_size
}

output "name_prefix" {
  description = "Common name prefix for resources"
  value       = local.name_prefix
}

output "common_tags" {
  description = "Common tags for all resources"
  value       = local.common_tags
}

# VPC
output "vpc_cidr" {
  description = "VPC network range"
  value = "10.30.0.0/16"
}

output "secondary_cidr_blocks" {
  description = "Secondary VPC netwoork range"
  value = "198.19.0.0/16"
}
output "azs" {
  description = "Availability zones"
  value = ["us-east-1a", "us-east-1c", "us-east-1b"]
}

output "public_subnets" {
  description = "Public subnet ranges"
  value = ["10.30.10.0/24", "10.30.11.0/24", "10.30.12.0/24"]
}

output "private_subnets" {
  description = "Private subnet ranges"
  value = ["10.30.20.0/24", "10.30.21.0/24", "10.30.22.0/24"]
}

output "database_subnets" {
  description = "Private subnet ranges"
  value = ["10.30.30.0/24", "10.30.31.0/24", "10.30.32.0/24"]
}


