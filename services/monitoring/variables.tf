variable "bucket" {
  description = "Name of the S3 bucket storing Terraform state"
  type        = string
}

# SQS Monitoring Configuration
variable "sqs_queue_depth_threshold" {
  description = "Threshold for SQS queue depth alarm"
  type        = number
  default     = 10
}

variable "sqs_queue_depth_evaluation_periods" {
  description = "Number of evaluation periods for queue depth alarm"
  type        = number
  default     = 2
}

variable "sqs_dlq_threshold" {
  description = "Threshold for SQS DLQ messages alarm"
  type        = number
  default     = 0
}

variable "sqs_dlq_evaluation_periods" {
  description = "Number of evaluation periods for DLQ alarm"
  type        = number
  default     = 1
}

# S3 Monitoring Configuration
variable "s3_storage_threshold_gb" {
  description = "Threshold for S3 storage usage alarm in GB"
  type        = number
  default     = 100
}

variable "s3_request_threshold" {
  description = "Threshold for S3 request rate alarm"
  type        = number
  default     = 1000
}

# S3 Frontend Monitoring Configuration
variable "s3_frontend_threshold_gb" {
  description = "Threshold for S3 frontend storage usage alarm in GB"
  type        = number
  default     = 5
}

variable "s3_frontend_request_threshold" {
  description = "Threshold for S3 frontend request rate alarm"
  type        = number
  default     = 500
}

# Cognito Monitoring Configuration
variable "cognito_signin_failure_threshold" {
  description = "Threshold for Cognito sign-in failures"
  type        = number
  default     = 20
}

variable "cognito_token_failure_threshold" {
  description = "Threshold for Cognito token refresh failures"
  type        = number
  default     = 10
}

# SNS Monitoring Configuration
variable "sns_failure_threshold" {
  description = "Threshold for SNS delivery failures"
  type        = number
  default     = 5
}

# CloudWatch Logs Configuration
variable "log_retention_days" {
  description = "CloudWatch logs retention period in days"
  type        = number
  default     = 14
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "alarm_period_seconds" {
  description = "Period for CloudWatch alarms in seconds"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
variable "cognito_auth_failure_threshold" {
  description = "Threshold for Cognito authentication failures from logs"
  type        = number
  default     = 15
}
#--------------------------------------------------------------
# API Gateway Alarm Variables
#--------------------------------------------------------------

variable "api_gateway_4xx_threshold" {
  description = "Threshold for API Gateway 4xx errors"
  type        = number
  default     = 10
}

variable "api_gateway_5xx_threshold" {
  description = "Threshold for API Gateway 5xx errors"
  type        = number
  default     = 5
}

variable "api_gateway_latency_threshold" {
  description = "Threshold for API Gateway latency in milliseconds"
  type        = number
  default     = 2000
}

variable "api_gateway_integration_latency_threshold" {
  description = "Threshold for API Gateway integration latency in milliseconds"
  type        = number
  default     = 1500
}

variable "api_gateway_error_evaluation_periods" {
  description = "Number of evaluation periods for API Gateway error alarms"
  type        = number
  default     = 2
}

variable "api_gateway_latency_evaluation_periods" {
  description = "Number of evaluation periods for API Gateway latency alarms"
  type        = number
  default     = 3
}

variable "api_gateway_request_count_threshold" {
  description = "Threshold for API Gateway high request count"
  type        = number
  default     = 1000
}

variable "websocket_connection_threshold" {
  description = "Threshold for WebSocket concurrent connections"
  type        = number
  default     = 1000
}
