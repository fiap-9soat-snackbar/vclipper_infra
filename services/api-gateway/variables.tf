#--------------------------------------------------------------
# API Gateway Variables
#--------------------------------------------------------------

variable "bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "vclipper-terraform-state-dev-rmxhnjty"
}

variable "backend_alb_dns_name" {
  description = "DNS name of the Application Load Balancer for backend services"
  type        = string
  default     = "teste-744402398.us-east-1.elb.amazonaws.com"  # Default for development/testing
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

# CloudWatch Logs Configuration
variable "log_retention_days" {
  description = "CloudWatch logs retention period in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
