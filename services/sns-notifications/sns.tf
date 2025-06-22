#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------

# Get current AWS account ID
data "aws_caller_identity" "current" {}

#--------------------------------------------------------------
# Local Values
#--------------------------------------------------------------

locals {
  success_topic_name = var.success_topic_name_override != "" ? var.success_topic_name_override : "${data.terraform_remote_state.global.outputs.project_name}-video-processing-success-${var.environment}"
  failure_topic_name = var.failure_topic_name_override != "" ? var.failure_topic_name_override : "${data.terraform_remote_state.global.outputs.project_name}-video-processing-failure-${var.environment}"
  
  common_tags = merge(var.tags, {
    Service = "sns-notifications"
    Purpose = "Video processing notifications"
  })
}

#--------------------------------------------------------------
# SNS Topics
#--------------------------------------------------------------

# Success notifications topic
resource "aws_sns_topic" "video_processing_success" {
  name = local.success_topic_name

  # Message delivery retry policy
  delivery_policy = jsonencode(jsondecode(file("${path.module}/policies/delivery_policy.json")))

  tags = merge(local.common_tags, {
    Name = "VClipper Video Processing Success"
    Type = "SuccessNotifications"
  })
}

# Failure notifications topic
resource "aws_sns_topic" "video_processing_failure" {
  name = local.failure_topic_name

  # Message delivery retry policy
  delivery_policy = jsonencode(jsondecode(file("${path.module}/policies/delivery_policy.json")))

  tags = merge(local.common_tags, {
    Name = "VClipper Video Processing Failure"
    Type = "FailureNotifications"
  })
}

#--------------------------------------------------------------
# Topic Policies
#--------------------------------------------------------------

# Success topic policy
resource "aws_sns_topic_policy" "video_processing_success_policy" {
  arn = aws_sns_topic.video_processing_success.arn
  policy = templatefile("${path.module}/policies/topic_policy_template.json", {
    topic_name = aws_sns_topic.video_processing_success.name,
    topic_arn  = aws_sns_topic.video_processing_success.arn,
    account_id = data.aws_caller_identity.current.account_id
  })
}

# Failure topic policy
resource "aws_sns_topic_policy" "video_processing_failure_policy" {
  arn = aws_sns_topic.video_processing_failure.arn
  policy = templatefile("${path.module}/policies/topic_policy_template.json", {
    topic_name = aws_sns_topic.video_processing_failure.name,
    topic_arn  = aws_sns_topic.video_processing_failure.arn,
    account_id = data.aws_caller_identity.current.account_id
  })
}

#--------------------------------------------------------------
# Email Subscriptions (Optional)
#--------------------------------------------------------------

# Admin email subscription for failure notifications
resource "aws_sns_topic_subscription" "admin_email_failure" {
  count     = var.enable_email_notifications && var.admin_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.video_processing_failure.arn
  protocol  = "email"
  endpoint  = var.admin_email

  # Email subscriptions require manual confirmation
  # The admin will receive a confirmation email
}

# Admin email subscription for success notifications (optional)
resource "aws_sns_topic_subscription" "admin_email_success" {
  count     = var.enable_email_notifications && var.admin_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.video_processing_success.arn
  protocol  = "email"
  endpoint  = var.admin_email
}

#--------------------------------------------------------------
# SMS Subscriptions (Optional)
#--------------------------------------------------------------

# Admin SMS subscription for critical failures
resource "aws_sns_topic_subscription" "admin_sms_failure" {
  count     = var.enable_sms_notifications && var.admin_phone_number != "" ? 1 : 0
  topic_arn = aws_sns_topic.video_processing_failure.arn
  protocol  = "sms"
  endpoint  = var.admin_phone_number
}
