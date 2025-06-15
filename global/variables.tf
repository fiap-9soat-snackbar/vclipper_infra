variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "vclipper"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "terraform_state_bucket" {
  description = "Name of the S3 bucket storing Terraform state"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
