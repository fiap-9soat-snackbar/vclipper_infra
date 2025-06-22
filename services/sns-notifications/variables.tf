variable "terraform_state_bucket" {
  description = "Name of the S3 bucket storing Terraform state"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "success_topic_name_override" {
  description = "Override the default success topic name (optional)"
  type        = string
  default     = ""
}

variable "failure_topic_name_override" {
  description = "Override the default failure topic name (optional)"
  type        = string
  default     = ""
}

variable "admin_email" {
  description = "Admin email address for failure notifications"
  type        = string
  default     = ""
}

variable "enable_email_notifications" {
  description = "Enable email notifications for admin"
  type        = bool
  default     = false
}

variable "enable_sms_notifications" {
  description = "Enable SMS notifications for critical failures"
  type        = bool
  default     = false
}

variable "admin_phone_number" {
  description = "Admin phone number for SMS notifications (format: +1234567890)"
  type        = string
  default     = ""
}

variable "message_retention_seconds" {
  description = "Message retention period for failed deliveries"
  type        = number
  default     = 1209600  # 14 days
}

variable "delivery_retry_policy" {
  description = "Number of retry attempts for message delivery"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
