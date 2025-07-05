variable "terraform_state_bucket" {
  description = "Name of the S3 bucket storing Terraform state"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "queue_name_override" {
  description = "Override the default queue name (optional)"
  type        = string
  default     = ""
}

variable "dlq_name_override" {
  description = "Override the default dead letter queue name (optional)"
  type        = string
  default     = ""
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue (seconds)"
  type        = number
  default     = 300  # 5 minutes - should be longer than typical processing time
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message"
  type        = number
  default     = 1209600  # 14 days (maximum)
}

variable "max_receive_count" {
  description = "Maximum number of times a message can be received before moving to DLQ"
  type        = number
  default     = 3
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of messages is delayed"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive"
  type        = number
  default     = 20  # Enable long polling
}

variable "enable_content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# VClipping microservice queue configuration
variable "enable_vclipping_queues" {
  description = "Enable creation of vclipping microservice queues"
  type        = bool
  default     = true
}

variable "vclipping_processing_queue_name_override" {
  description = "Override the default vclipping processing queue name (optional)"
  type        = string
  default     = ""
}

variable "vclipping_results_queue_name_override" {
  description = "Override the default vclipping results queue name (optional)"
  type        = string
  default     = ""
}
