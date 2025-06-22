# SNS Topic outputs
output "success_topic_name" {
  description = "Name of the success notifications SNS topic"
  value       = aws_sns_topic.video_processing_success.name
}

output "success_topic_arn" {
  description = "ARN of the success notifications SNS topic"
  value       = aws_sns_topic.video_processing_success.arn
}

output "failure_topic_name" {
  description = "Name of the failure notifications SNS topic"
  value       = aws_sns_topic.video_processing_failure.name
}

output "failure_topic_arn" {
  description = "ARN of the failure notifications SNS topic"
  value       = aws_sns_topic.video_processing_failure.arn
}

# Subscription outputs
output "admin_email_subscriptions" {
  description = "List of admin email subscription ARNs"
  value = concat(
    var.enable_email_notifications && var.admin_email != "" ? [aws_sns_topic_subscription.admin_email_failure[0].arn] : [],
    var.enable_email_notifications && var.admin_email != "" ? [aws_sns_topic_subscription.admin_email_success[0].arn] : []
  )
}

output "admin_sms_subscriptions" {
  description = "List of admin SMS subscription ARNs"
  value = var.enable_sms_notifications && var.admin_phone_number != "" ? [aws_sns_topic_subscription.admin_sms_failure[0].arn] : []
}

# Configuration outputs for applications
output "delivery_retry_policy" {
  description = "Number of retry attempts for message delivery"
  value       = var.delivery_retry_policy
}

output "message_retention_seconds" {
  description = "Message retention period for failed deliveries"
  value       = var.message_retention_seconds
}

# Integration endpoints for backend services
output "notification_endpoints" {
  description = "SNS topic endpoints for backend integration"
  value = {
    success_topic_arn = aws_sns_topic.video_processing_success.arn
    failure_topic_arn = aws_sns_topic.video_processing_failure.arn
    success_topic_name = aws_sns_topic.video_processing_success.name
    failure_topic_name = aws_sns_topic.video_processing_failure.name
  }
  sensitive = false
}
