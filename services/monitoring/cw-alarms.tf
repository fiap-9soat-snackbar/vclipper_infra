#--------------------------------------------------------------
# CloudWatch Alarms
#--------------------------------------------------------------

#--------------------------------------------------------------
# Local Values
#--------------------------------------------------------------

locals {
  common_tags = merge(var.tags, {
    Service = "monitoring"
    Purpose = "Infrastructure monitoring and alerting"
  })
  
  # SNS topic ARNs for alarm actions
  failure_topic_arn = data.terraform_remote_state.sns_notifications.outputs.failure_topic_arn
  success_topic_arn = data.terraform_remote_state.sns_notifications.outputs.success_topic_arn
}

#--------------------------------------------------------------
# SQS CloudWatch Alarms
#--------------------------------------------------------------

# SQS Queue Depth Alarm
resource "aws_cloudwatch_metric_alarm" "sqs_queue_depth" {
  alarm_name          = "${data.terraform_remote_state.sqs.outputs.queue_name}-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.sqs_queue_depth_evaluation_periods
  metric_name         = "ApproximateNumberOfVisibleMessages"
  namespace           = "AWS/SQS"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.sqs_queue_depth_threshold
  alarm_description   = "This metric monitors SQS queue depth for video processing - indicates processing bottleneck"
  
  # SNS Actions
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]
  
  dimensions = {
    QueueName = data.terraform_remote_state.sqs.outputs.queue_name
  }

  tags = merge(local.common_tags, {
    AlarmType = "SQS"
    Severity  = "High"
    Resource  = data.terraform_remote_state.sqs.outputs.queue_name
  })
}

# SQS Dead Letter Queue Messages Alarm
resource "aws_cloudwatch_metric_alarm" "sqs_dlq_messages" {
  alarm_name          = "${data.terraform_remote_state.sqs.outputs.dlq_name}-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.sqs_dlq_evaluation_periods
  metric_name         = "ApproximateNumberOfVisibleMessages"
  namespace           = "AWS/SQS"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.sqs_dlq_threshold
  alarm_description   = "This metric monitors messages in dead letter queue - indicates processing failures"
  
  # SNS Actions - DLQ messages are always critical
  alarm_actions = [local.failure_topic_arn]
  
  dimensions = {
    QueueName = data.terraform_remote_state.sqs.outputs.dlq_name
  }

  tags = merge(local.common_tags, {
    AlarmType = "SQS"
    Severity  = "Critical"
    Resource  = data.terraform_remote_state.sqs.outputs.dlq_name
  })
}

# SQS Message Age Alarm (messages stuck in queue)
resource "aws_cloudwatch_metric_alarm" "sqs_message_age" {
  alarm_name          = "${data.terraform_remote_state.sqs.outputs.queue_name}-message-age"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = var.alarm_period_seconds
  statistic           = "Maximum"
  threshold           = "900"  # 15 minutes
  alarm_description   = "This metric monitors age of oldest message in queue - indicates processing delays"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]
  
  dimensions = {
    QueueName = data.terraform_remote_state.sqs.outputs.queue_name
  }

  tags = merge(local.common_tags, {
    AlarmType = "SQS"
    Severity  = "Medium"
    Resource  = data.terraform_remote_state.sqs.outputs.queue_name
  })
}

#--------------------------------------------------------------
# S3 Video Storage CloudWatch Alarms
#--------------------------------------------------------------

# S3 Video Storage Bucket Size Alarm
resource "aws_cloudwatch_metric_alarm" "s3_video_bucket_size" {
  alarm_name          = "${data.terraform_remote_state.video_storage.outputs.bucket_name}-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400"  # Daily check
  statistic           = "Average"
  threshold           = var.s3_storage_threshold_gb * 1024 * 1024 * 1024  # Convert GB to bytes
  alarm_description   = "This metric monitors S3 video storage bucket usage - indicates high storage consumption"
  
  alarm_actions = [local.failure_topic_arn]
  
  dimensions = {
    BucketName  = data.terraform_remote_state.video_storage.outputs.bucket_name
    StorageType = "StandardStorage"
  }

  tags = merge(local.common_tags, {
    AlarmType = "S3"
    Severity  = "Medium"
    Resource  = data.terraform_remote_state.video_storage.outputs.bucket_name
  })
}

# S3 Video Storage Request Rate Alarm
resource "aws_cloudwatch_metric_alarm" "s3_video_request_rate" {
  alarm_name          = "${data.terraform_remote_state.video_storage.outputs.bucket_name}-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "AllRequests"
  namespace           = "AWS/S3"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.s3_request_threshold
  alarm_description   = "This metric monitors S3 video storage request rate - indicates high API usage"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]
  
  dimensions = {
    BucketName = data.terraform_remote_state.video_storage.outputs.bucket_name
  }

  tags = merge(local.common_tags, {
    AlarmType = "S3"
    Severity  = "Low"
    Resource  = data.terraform_remote_state.video_storage.outputs.bucket_name
  })
}

#--------------------------------------------------------------
# S3 Frontend Hosting CloudWatch Alarms
#--------------------------------------------------------------

# S3 Frontend Bucket Size Alarm
resource "aws_cloudwatch_metric_alarm" "s3_frontend_bucket_size" {
  alarm_name          = "${data.terraform_remote_state.frontend_hosting.outputs.bucket_name}-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400"  # Daily check
  statistic           = "Average"
  threshold           = var.s3_frontend_threshold_gb * 1024 * 1024 * 1024  # Convert GB to bytes
  alarm_description   = "This metric monitors S3 frontend bucket usage - indicates high frontend storage consumption"
  
  alarm_actions = [local.failure_topic_arn]
  
  dimensions = {
    BucketName  = data.terraform_remote_state.frontend_hosting.outputs.bucket_name
    StorageType = "StandardStorage"
  }

  tags = merge(local.common_tags, {
    AlarmType = "S3"
    Severity  = "Low"
    Resource  = data.terraform_remote_state.frontend_hosting.outputs.bucket_name
  })
}

# S3 Frontend Request Rate Alarm
resource "aws_cloudwatch_metric_alarm" "s3_frontend_request_rate" {
  alarm_name          = "${data.terraform_remote_state.frontend_hosting.outputs.bucket_name}-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "AllRequests"
  namespace           = "AWS/S3"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.s3_frontend_request_threshold
  alarm_description   = "This metric monitors S3 frontend request rate - indicates high website traffic"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]
  
  dimensions = {
    BucketName = data.terraform_remote_state.frontend_hosting.outputs.bucket_name
  }

  tags = merge(local.common_tags, {
    AlarmType = "S3"
    Severity  = "Medium"
    Resource  = data.terraform_remote_state.frontend_hosting.outputs.bucket_name
  })
}

# S3 Frontend 4xx Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "s3_frontend_4xx_errors" {
  alarm_name          = "${data.terraform_remote_state.frontend_hosting.outputs.bucket_name}-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4xxErrors"
  namespace           = "AWS/S3"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors S3 frontend 4xx errors - indicates client-side issues or missing files"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]
  
  dimensions = {
    BucketName = data.terraform_remote_state.frontend_hosting.outputs.bucket_name
  }

  tags = merge(local.common_tags, {
    AlarmType = "S3"
    Severity  = "Medium"
    Resource  = data.terraform_remote_state.frontend_hosting.outputs.bucket_name
  })
}

#--------------------------------------------------------------
# Cognito CloudWatch Alarms
#--------------------------------------------------------------

# Cognito Sign-in Failures Alarm
resource "aws_cloudwatch_metric_alarm" "cognito_signin_failures" {
  alarm_name          = "${data.terraform_remote_state.cognito.outputs.user_pool_id}-signin-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "SignInFailures"
  namespace           = "AWS/Cognito"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.cognito_signin_failure_threshold
  alarm_description   = "This metric monitors Cognito sign-in failures - indicates authentication issues or attacks"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]
  
  dimensions = {
    UserPool     = data.terraform_remote_state.cognito.outputs.user_pool_id
    UserPoolClient = data.terraform_remote_state.cognito.outputs.user_pool_client_id
  }

  tags = merge(local.common_tags, {
    AlarmType = "Cognito"
    Severity  = "High"
    Resource  = data.terraform_remote_state.cognito.outputs.user_pool_id
  })
}

# Cognito Token Refresh Failures Alarm
resource "aws_cloudwatch_metric_alarm" "cognito_token_refresh_failures" {
  alarm_name          = "${data.terraform_remote_state.cognito.outputs.user_pool_id}-token-refresh-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TokenRefreshFailures"
  namespace           = "AWS/Cognito"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.cognito_token_failure_threshold
  alarm_description   = "This metric monitors Cognito token refresh failures - indicates session management issues"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]
  
  dimensions = {
    UserPool     = data.terraform_remote_state.cognito.outputs.user_pool_id
    UserPoolClient = data.terraform_remote_state.cognito.outputs.user_pool_client_id
  }

  tags = merge(local.common_tags, {
    AlarmType = "Cognito"
    Severity  = "Medium"
    Resource  = data.terraform_remote_state.cognito.outputs.user_pool_id
  })
}

#--------------------------------------------------------------
# SNS CloudWatch Alarms
#--------------------------------------------------------------

# SNS Success Topic - Delivery Failures Alarm
resource "aws_cloudwatch_metric_alarm" "sns_success_delivery_failures" {
  alarm_name          = "${data.terraform_remote_state.sns_notifications.outputs.success_topic_name}-delivery-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfNotificationsFailed"
  namespace           = "AWS/SNS"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.sns_failure_threshold
  alarm_description   = "This metric monitors SNS success topic delivery failures - indicates notification system issues"
  
  # Use failure topic for success topic failures
  alarm_actions = [local.failure_topic_arn]
  
  dimensions = {
    TopicName = data.terraform_remote_state.sns_notifications.outputs.success_topic_name
  }

  tags = merge(local.common_tags, {
    AlarmType = "SNS"
    Severity  = "High"
    Resource  = data.terraform_remote_state.sns_notifications.outputs.success_topic_name
  })
}

# SNS Failure Topic - Delivery Failures Alarm
resource "aws_cloudwatch_metric_alarm" "sns_failure_delivery_failures" {
  alarm_name          = "${data.terraform_remote_state.sns_notifications.outputs.failure_topic_name}-delivery-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfNotificationsFailed"
  namespace           = "AWS/SNS"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.sns_failure_threshold
  alarm_description   = "This metric monitors SNS failure topic delivery failures - critical notification system issues"
  
  # For failure topic failures, we can't use SNS - this would need alternative notification
  # For now, we'll skip alarm_actions to avoid circular dependency
  alarm_actions = []
  
  dimensions = {
    TopicName = data.terraform_remote_state.sns_notifications.outputs.failure_topic_name
  }

  tags = merge(local.common_tags, {
    AlarmType = "SNS"
    Severity  = "Critical"
    Resource  = data.terraform_remote_state.sns_notifications.outputs.failure_topic_name
  })
}

# SNS Failure Topic - High Message Volume Alarm
resource "aws_cloudwatch_metric_alarm" "sns_failure_high_volume" {
  alarm_name          = "${data.terraform_remote_state.sns_notifications.outputs.failure_topic_name}-high-volume"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NumberOfMessagesPublished"
  namespace           = "AWS/SNS"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = "20"
  alarm_description   = "This metric monitors SNS failure topic message volume - indicates high system failure rate"
  
  alarm_actions = [local.failure_topic_arn]
  
  dimensions = {
    TopicName = data.terraform_remote_state.sns_notifications.outputs.failure_topic_name
  }

  tags = merge(local.common_tags, {
    AlarmType = "SNS"
    Severity  = "High"
    Resource  = data.terraform_remote_state.sns_notifications.outputs.failure_topic_name
  })
}

#--------------------------------------------------------------
# S3 Frontend Log-based CloudWatch Alarms
#--------------------------------------------------------------

# S3 Frontend 4xx Error Rate Alarm (from logs)
resource "aws_cloudwatch_metric_alarm" "s3_frontend_4xx_error_rate" {
  alarm_name          = "s3-frontend-4xx-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "S3Frontend4xxErrors"
  namespace           = "VClipper/S3Frontend"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors S3 frontend 4xx errors from access logs - indicates client-side issues"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "S3Frontend"
    Severity  = "Medium"
    Resource  = "S3FrontendLogs"
  })
}

# S3 Frontend 5xx Error Rate Alarm (from logs)
resource "aws_cloudwatch_metric_alarm" "s3_frontend_5xx_error_rate" {
  alarm_name          = "s3-frontend-5xx-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "S3Frontend5xxErrors"
  namespace           = "VClipper/S3Frontend"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors S3 frontend 5xx errors from access logs - indicates server-side issues"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "S3Frontend"
    Severity  = "High"
    Resource  = "S3FrontendLogs"
  })
}

#--------------------------------------------------------------
# Cognito Log-based CloudWatch Alarms
#--------------------------------------------------------------

# Cognito Authentication Failures Alarm (from logs)
resource "aws_cloudwatch_metric_alarm" "cognito_auth_failure_rate" {
  alarm_name          = "cognito-auth-failure-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CognitoAuthFailures"
  namespace           = "VClipper/Cognito"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.cognito_auth_failure_threshold
  alarm_description   = "This metric monitors Cognito authentication failures from logs - indicates auth issues or attacks"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "Cognito"
    Severity  = "High"
    Resource  = "CognitoLogs"
  })
}

# Cognito Suspicious Activity Alarm (from logs)
resource "aws_cloudwatch_metric_alarm" "cognito_suspicious_activity_rate" {
  alarm_name          = "cognito-suspicious-activity-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CognitoSuspiciousActivity"
  namespace           = "VClipper/Cognito"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = "3"
  alarm_description   = "This metric monitors Cognito suspicious activity from logs - indicates potential security threats"
  
  alarm_actions = [local.failure_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "Cognito"
    Severity  = "Critical"
    Resource  = "CognitoLogs"
  })
}
#--------------------------------------------------------------
# Application Log-based CloudWatch Alarms
#--------------------------------------------------------------

# Application Error Rate Alarm (from log metrics)
resource "aws_cloudwatch_metric_alarm" "application_error_rate" {
  alarm_name          = "vclipper-application-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ApplicationErrors"
  namespace           = "VClipper/Application"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors application error rate - indicates application issues"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "Application"
    Severity  = "High"
    Resource  = "ApplicationLogs"
  })
}

# Video Processing Failure Rate Alarm (from log metrics)
resource "aws_cloudwatch_metric_alarm" "video_processing_failure_rate" {
  alarm_name          = "vclipper-video-processing-failure-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "VideoProcessingFailures"
  namespace           = "VClipper/VideoProcessing"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors video processing failure rate - indicates processing issues"
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "VideoProcessing"
    Severity  = "Critical"
    Resource  = "VideoProcessingLogs"
  })
}

#--------------------------------------------------------------
# API Gateway CloudWatch Alarms
#--------------------------------------------------------------

# API Gateway 4xx Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "api_gateway_4xx_errors" {
  alarm_name          = "${data.terraform_remote_state.global.outputs.project_name}-api-gateway-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.api_gateway_error_evaluation_periods
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGatewayV2"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.api_gateway_4xx_threshold
  alarm_description   = "This metric monitors API Gateway 4xx errors - indicates client-side issues"
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    ApiId = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  }
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "APIGateway"
    Severity  = "Warning"
    Resource  = "API-4xxErrors"
  })
}

# API Gateway 5xx Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx_errors" {
  alarm_name          = "${data.terraform_remote_state.global.outputs.project_name}-api-gateway-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.api_gateway_error_evaluation_periods
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGatewayV2"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.api_gateway_5xx_threshold
  alarm_description   = "This metric monitors API Gateway 5xx errors - indicates server-side issues"
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    ApiId = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  }
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "APIGateway"
    Severity  = "Critical"
    Resource  = "API-5xxErrors"
  })
}

# API Gateway High Latency Alarm
resource "aws_cloudwatch_metric_alarm" "api_gateway_latency" {
  alarm_name          = "${data.terraform_remote_state.global.outputs.project_name}-api-gateway-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.api_gateway_latency_evaluation_periods
  metric_name         = "Latency"
  namespace           = "AWS/ApiGatewayV2"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.api_gateway_latency_threshold
  alarm_description   = "This metric monitors API Gateway latency - indicates performance issues"
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    ApiId = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  }
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "APIGateway"
    Severity  = "Warning"
    Resource  = "API-Latency"
  })
}

# API Gateway Integration Latency Alarm
resource "aws_cloudwatch_metric_alarm" "api_gateway_integration_latency" {
  alarm_name          = "${data.terraform_remote_state.global.outputs.project_name}-api-gateway-integration-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.api_gateway_latency_evaluation_periods
  metric_name         = "IntegrationLatency"
  namespace           = "AWS/ApiGatewayV2"
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.api_gateway_integration_latency_threshold
  alarm_description   = "This metric monitors API Gateway integration latency - indicates backend issues"
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    ApiId = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  }
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "APIGateway"
    Severity  = "Warning"
    Resource  = "API-IntegrationLatency"
  })
}

# API Gateway Request Count Threshold Alarm (Simplified)
resource "aws_cloudwatch_metric_alarm" "api_gateway_high_request_count" {
  alarm_name          = "${data.terraform_remote_state.global.outputs.project_name}-api-gateway-high-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Count"
  namespace           = "AWS/ApiGatewayV2"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.api_gateway_request_count_threshold
  alarm_description   = "This metric monitors API Gateway request count - indicates high traffic"
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    ApiId = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
  }
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "APIGateway"
    Severity  = "Info"
    Resource  = "API-HighRequests"
  })
}

# WebSocket API Connection Count (Future)
resource "aws_cloudwatch_metric_alarm" "websocket_connection_count" {
  alarm_name          = "${data.terraform_remote_state.global.outputs.project_name}-websocket-connection-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ConnectCount"
  namespace           = "AWS/ApiGatewayV2"
  period              = var.alarm_period_seconds
  statistic           = "Sum"
  threshold           = var.websocket_connection_threshold
  alarm_description   = "This metric monitors WebSocket connection count - indicates high concurrent usage"
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    ApiId = data.terraform_remote_state.api_gateway.outputs.websocket_api_id
  }
  
  alarm_actions = [local.failure_topic_arn]
  ok_actions    = [local.success_topic_arn]

  tags = merge(local.common_tags, {
    AlarmType = "WebSocket"
    Severity  = "Info"
    Resource  = "WebSocket-Connections"
  })
}
