variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution that will access this S3 bucket"
  type        = string
  default     = ""
}

variable "allowed_origins" {
  description = "List of allowed origins for CORS configuration"
  type        = list(string)
  default     = ["*"]
}

variable "old_version_retention_days" {
  description = "Number of days to retain old object versions"
  type        = number
  default     = 30
}

variable "enable_deployment_notifications" {
  description = "Enable S3 bucket notifications for deployment automation"
  type        = bool
  default     = false
}

variable "bucket_name_override" {
  description = "Override the default bucket name (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition = contains([
      "PriceClass_All",
      "PriceClass_200", 
      "PriceClass_100"
    ], var.cloudfront_price_class)
    error_message = "CloudFront price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}
