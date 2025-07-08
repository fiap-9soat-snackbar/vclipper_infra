# SQS Queue outputs
output "queue_name" {
  description = "Name of the video processing SQS queue"
  value       = aws_sqs_queue.video_processing.name
}

output "queue_arn" {
  description = "ARN of the video processing SQS queue"
  value       = aws_sqs_queue.video_processing.arn
}

output "queue_url" {
  description = "URL of the video processing SQS queue"
  value       = aws_sqs_queue.video_processing.url
}

output "dlq_name" {
  description = "Name of the dead letter queue"
  value       = aws_sqs_queue.video_processing_dlq.name
}

output "dlq_arn" {
  description = "ARN of the dead letter queue"
  value       = aws_sqs_queue.video_processing_dlq.arn
}

output "dlq_url" {
  description = "URL of the dead letter queue"
  value       = aws_sqs_queue.video_processing_dlq.url
}

# Configuration outputs for applications
output "visibility_timeout_seconds" {
  description = "Visibility timeout for the queue in seconds"
  value       = var.visibility_timeout_seconds
}

output "max_receive_count" {
  description = "Maximum number of times a message can be received before moving to DLQ"
  value       = jsondecode(file("${path.module}/policies/redrive_policy.json")).maxReceiveCount
}

output "message_retention_seconds" {
  description = "Number of seconds Amazon SQS retains a message"
  value       = var.message_retention_seconds
}

#--------------------------------------------------------------
# VClipping Results Queue Outputs (vclipping → vclipper_processing)
#--------------------------------------------------------------

# VClipping Results Queue outputs
output "vclipping_results_queue_name" {
  description = "Name of the vclipping results SQS queue"
  value       = aws_sqs_queue.vclipping_results.name
}

output "vclipping_results_queue_arn" {
  description = "ARN of the vclipping results SQS queue"
  value       = aws_sqs_queue.vclipping_results.arn
}

output "vclipping_results_queue_url" {
  description = "URL of the vclipping results SQS queue"
  value       = aws_sqs_queue.vclipping_results.url
}

output "vclipping_results_dlq_name" {
  description = "Name of the vclipping results dead letter queue"
  value       = aws_sqs_queue.vclipping_results_dlq.name
}

output "vclipping_results_dlq_arn" {
  description = "ARN of the vclipping results dead letter queue"
  value       = aws_sqs_queue.vclipping_results_dlq.arn
}

output "vclipping_results_dlq_url" {
  description = "URL of the vclipping results dead letter queue"
  value       = aws_sqs_queue.vclipping_results_dlq.url
}
