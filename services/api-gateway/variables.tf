#--------------------------------------------------------------
# API Gateway Variables
#--------------------------------------------------------------

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
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "terraform_state_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "vclipper-terraform-state-dev-rmxhnjty"
}

variable "backend_alb_dns_name" {
  description = "DNS name of the Application Load Balancer for backend services"
  type        = string
  default     = "localhost:8080"  # Default for development/testing
}

# Optional: Custom domain configuration (future)
variable "custom_domain_name" {
  description = "Custom domain name for the API Gateway"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for custom domain"
  type        = string
  default     = ""
}

# API Gateway configuration
variable "throttling_burst_limit" {
  description = "API Gateway throttling burst limit"
  type        = number
  default     = 100
}

variable "throttling_rate_limit" {
  description = "API Gateway throttling rate limit"
  type        = number
  default     = 50
}



# CORS configuration
variable "cors_allow_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]  # TODO: Restrict in production
}

variable "cors_allow_headers" {
  description = "List of allowed headers for CORS"
  type        = list(string)
  default     = ["content-type", "authorization", "x-amz-date", "x-api-key", "x-amz-security-token"]
}

variable "cors_allow_methods" {
  description = "List of allowed HTTP methods for CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}
