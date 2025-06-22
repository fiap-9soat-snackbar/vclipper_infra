variable "terraform_state_bucket" {
  description = "Name of the S3 bucket storing Terraform state"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "bucket_name_override" {
  description = "Override the default bucket name (optional)"
  type        = string
  default     = ""
}

variable "video_retention_days" {
  description = "Number of days to retain uploaded videos"
  type        = number
  default     = 15
}

variable "images_retention_days" {
  description = "Number of days to retain generated image zip files"
  type        = number
  default     = 45
}

variable "presigned_url_expiration" {
  description = "Default expiration time for pre-signed URLs in seconds"
  type        = number
  default     = 3600  # 1 hour
}

variable "max_video_size_mb" {
  description = "Maximum video file size in MB"
  type        = number
  default     = 500
}

variable "allowed_video_types" {
  description = "List of allowed video MIME types"
  type        = list(string)
  default     = [
    "video/mp4",
    "video/avi",
    "video/mov",
    "video/wmv",
    "video/flv",
    "video/webm"
  ]
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable S3 bucket server-side encryption"
  type        = bool
  default     = true
}

variable "allowed_origins" {
  description = "List of allowed origins for CORS configuration"
  type        = list(string)
  default     = [
    "http://localhost:3000",
    "http://localhost:3001",
    "http://127.0.0.1:3000"
  ]
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
