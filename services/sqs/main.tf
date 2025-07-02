

#--------------------------------------------------------------
# Local Values
#--------------------------------------------------------------

locals {
  queue_name = var.queue_name_override != "" ? var.queue_name_override : "${data.terraform_remote_state.global.outputs.project_name}-video-processing-${data.terraform_remote_state.global.outputs.environment}"
  dlq_name   = var.dlq_name_override != "" ? var.dlq_name_override : "${data.terraform_remote_state.global.outputs.project_name}-video-processing-dlq-${data.terraform_remote_state.global.outputs.environment}"
  
  common_tags = merge(var.tags, {
    Service = "sqs-processing"
    Purpose = "Video processing queue"
  })
}

#--------------------------------------------------------------
# SQS Queue Resources
#--------------------------------------------------------------

# Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "video_processing_dlq" {
  name                      = local.dlq_name
  fifo_queue                = var.fifo_queue
  message_retention_seconds = var.message_retention_seconds
  
  tags = merge(local.common_tags, {
    Name = "VClipper Video Processing DLQ"
    Type = "DeadLetterQueue"
  })
}

# Main Video Processing Queue
resource "aws_sqs_queue" "video_processing" {
  name                       = local.queue_name
  fifo_queue                 = var.fifo_queue
  delay_seconds              = var.delay_seconds
  max_message_size           = 262144  # 256 KB (maximum for SQS)
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  
  # Content-based deduplication for FIFO queues
  content_based_deduplication = var.fifo_queue ? var.enable_content_based_deduplication : null

  tags = merge(local.common_tags, {
    Name = "VClipper Video Processing Queue"
    Type = "ProcessingQueue"
  })
}

#--------------------------------------------------------------
# Queue Policies
#--------------------------------------------------------------

# Main Queue Policy
resource "aws_sqs_queue_policy" "video_processing_policy" {
  queue_url = aws_sqs_queue.video_processing.id
  policy = templatefile("${path.module}/policies/main_queue_policy_template.json", {
    queue_name     = aws_sqs_queue.video_processing.name,
    queue_arn      = aws_sqs_queue.video_processing.arn,
    account_id     = data.aws_caller_identity.current.account_id,
    s3_bucket_arn  = data.terraform_remote_state.video_storage.outputs.bucket_arn
  })
}

# DLQ Policy
resource "aws_sqs_queue_policy" "video_processing_dlq_policy" {
  queue_url = aws_sqs_queue.video_processing_dlq.id
  policy = templatefile("${path.module}/policies/dlq_policy_template.json", {
    queue_name       = aws_sqs_queue.video_processing_dlq.name,
    queue_arn        = aws_sqs_queue.video_processing_dlq.arn,
    account_id       = data.aws_caller_identity.current.account_id,
    source_queue_arn = aws_sqs_queue.video_processing.arn
  })
}

#--------------------------------------------------------------
# Redrive Policies
#--------------------------------------------------------------

# Redrive policy for the main queue
# This sends messages to the DLQ after the specified number of failures
resource "aws_sqs_queue_redrive_policy" "video_processing_redrive_policy" {
  queue_url = aws_sqs_queue.video_processing.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.video_processing_dlq.arn
    maxReceiveCount     = jsondecode(file("${path.module}/policies/redrive_policy.json")).maxReceiveCount
  })
}

# Redrive allow policy for the DLQ
# This controls which source queues can use this queue as DLQ
resource "aws_sqs_queue_redrive_allow_policy" "video_processing_dlq_redrive_allow_policy" {
  queue_url = aws_sqs_queue.video_processing_dlq.id
  redrive_allow_policy = jsonencode({
    redrivePermission = jsondecode(file("${path.module}/policies/dlq_allow_policy.json")).redrivePermission
    sourceQueueArns   = [aws_sqs_queue.video_processing.arn]
  })
}
