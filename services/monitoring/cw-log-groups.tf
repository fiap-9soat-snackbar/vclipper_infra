#--------------------------------------------------------------
# CloudWatch Log Groups
#--------------------------------------------------------------

# EKS Cluster Logs
resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "/aws/eks/vclipper/cluster"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "EKS"
    Purpose = "EKS cluster control plane logs"
  })
}

# Lambda Authorizer Logs
resource "aws_cloudwatch_log_group" "lambda_authorizer_logs" {
  name              = "/aws/lambda/vclipper-authorizer"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "Lambda"
    Purpose = "Lambda authorizer function logs"
  })
}

# S3 Frontend Hosting Access Logs
resource "aws_cloudwatch_log_group" "s3_frontend_access_logs" {
  name              = "/aws/s3/vclipper-frontend"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "S3Frontend"
    Purpose = "S3 frontend hosting access logs"
  })
}

# S3 Video Storage Access Logs
resource "aws_cloudwatch_log_group" "s3_video_storage_logs" {
  name              = "/aws/s3/vclipper-video-storage"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "S3VideoStorage"
    Purpose = "S3 video storage access logs"
  })
}

# SQS Queue Logs
resource "aws_cloudwatch_log_group" "sqs_logs" {
  name              = "/aws/sqs/vclipper"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "SQS"
    Purpose = "SQS queue processing logs"
  })
}

# SNS Topic Logs
resource "aws_cloudwatch_log_group" "sns_logs" {
  name              = "/aws/sns/vclipper"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "SNS"
    Purpose = "SNS topic delivery logs"
  })
}

# Log group for Cognito authentication logs
resource "aws_cloudwatch_log_group" "cognito_logs" {
  name              = "/aws/cognito/vclipper"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "Cognito"
    Purpose = "Cognito authentication and user management logs"
  })
}

#--------------------------------------------------------------
# Application Component Log Groups
#--------------------------------------------------------------

# Frontend Application Logs (vclipper_fe)
resource "aws_cloudwatch_log_group" "app_frontend_logs" {
  name              = "/aws/application/vclipper-frontend"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "ApplicationFrontend"
    Purpose = "React frontend logs"
    Component = "vclipper_fe"
  })
}

# Video Processing Workflow Logs (vclipper_processing)
resource "aws_cloudwatch_log_group" "app_processing_logs" {
  name              = "/aws/application/vclipper-processing"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "ApplicationProcessing"
    Purpose = "Video processing workflow logs"
    Component = "vclipper_processing"
  })
}

# Video Clipping Service Logs (vclipping)
resource "aws_cloudwatch_log_group" "app_clipping_logs" {
  name              = "/aws/application/vclipper-clipping"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "ApplicationClipping"
    Purpose = "Video clipping service logs"
    Component = "vclipping"
  })
}

# User Management Service Logs (vclipper_user)
resource "aws_cloudwatch_log_group" "app_user_logs" {
  name              = "/aws/application/vclipper-user"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    LogType = "ApplicationUser"
    Purpose = "User management service logs"
    Component = "vclipper_user"
  })
}

#--------------------------------------------------------------
# CloudWatch Log Metric Filters
#--------------------------------------------------------------

# Metric filter for processing component errors
resource "aws_cloudwatch_log_metric_filter" "app_processing_errors" {
  name           = "vclipper-app-processing-errors"
  log_group_name = aws_cloudwatch_log_group.app_processing_logs.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", ...]"

  metric_transformation {
    name      = "AppProcessingErrors"
    namespace = "VClipper/Application"
    value     = "1"
  }
}

# Metric filter for video processing failures
resource "aws_cloudwatch_log_metric_filter" "video_processing_failures" {
  name           = "vclipper-video-processing-failures"
  log_group_name = aws_cloudwatch_log_group.app_processing_logs.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", message=\"*processing failed*\", ...]"

  metric_transformation {
    name      = "VideoProcessingFailures"
    namespace = "VClipper/VideoProcessing"
    value     = "1"
  }
}

# Metric filter for successful video processing
resource "aws_cloudwatch_log_metric_filter" "video_processing_success" {
  name           = "vclipper-video-processing-success"
  log_group_name = aws_cloudwatch_log_group.app_processing_logs.name
  pattern        = "[timestamp, request_id, level=\"INFO\", message=\"*processing completed*\", ...]"

  metric_transformation {
    name      = "VideoProcessingSuccess"
    namespace = "VClipper/VideoProcessing"
    value     = "1"
  }
}

# Metric filter for frontend errors
resource "aws_cloudwatch_log_metric_filter" "frontend_errors" {
  name           = "vclipper-frontend-errors"
  log_group_name = aws_cloudwatch_log_group.app_frontend_logs.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", ...]"

  metric_transformation {
    name      = "FrontendErrors"
    namespace = "VClipper/Frontend"
    value     = "1"
  }
}

# Metric filter for clipping service errors
resource "aws_cloudwatch_log_metric_filter" "clipping_errors" {
  name           = "vclipper-clipping-errors"
  log_group_name = aws_cloudwatch_log_group.app_clipping_logs.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", ...]"

  metric_transformation {
    name      = "ClippingErrors"
    namespace = "VClipper/Clipping"
    value     = "1"
  }
}

# Metric filter for user service errors
resource "aws_cloudwatch_log_metric_filter" "user_service_errors" {
  name           = "vclipper-user-service-errors"
  log_group_name = aws_cloudwatch_log_group.app_user_logs.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", ...]"

  metric_transformation {
    name      = "UserServiceErrors"
    namespace = "VClipper/UserService"
    value     = "1"
  }
}

# Metric filter for S3 frontend 4xx errors
resource "aws_cloudwatch_log_metric_filter" "s3_frontend_4xx_errors" {
  name           = "vclipper-s3-frontend-4xx-errors"
  log_group_name = aws_cloudwatch_log_group.s3_frontend_access_logs.name
  pattern        = "[timestamp, bucket_owner, bucket, time, remote_ip, requester, request_id, operation, key, request_uri, http_status_code=4*, ...]"

  metric_transformation {
    name      = "S3Frontend4xxErrors"
    namespace = "VClipper/S3Frontend"
    value     = "1"
    unit      = "None"
  }
}

# Metric filter for S3 frontend 5xx errors
resource "aws_cloudwatch_log_metric_filter" "s3_frontend_5xx_errors" {
  name           = "vclipper-s3-frontend-5xx-errors"
  log_group_name = aws_cloudwatch_log_group.s3_frontend_access_logs.name
  pattern        = "[timestamp, bucket_owner, bucket, time, remote_ip, requester, request_id, operation, key, request_uri, http_status_code=5*, ...]"

  metric_transformation {
    name      = "S3Frontend5xxErrors"
    namespace = "VClipper/S3Frontend"
    value     = "1"
    unit      = "None"
  }
}

# Metric filter for S3 video storage errors
resource "aws_cloudwatch_log_metric_filter" "s3_video_storage_errors" {
  name           = "vclipper-s3-video-storage-errors"
  log_group_name = aws_cloudwatch_log_group.s3_video_storage_logs.name
  pattern        = "[timestamp, bucket_owner, bucket, time, remote_ip, requester, request_id, operation, key, request_uri, http_status_code=4*||http_status_code=5*, ...]"

  metric_transformation {
    name      = "S3VideoStorageErrors"
    namespace = "VClipper/S3VideoStorage"
    value     = "1"
    unit      = "None"
  }
}

# Metric filter for Cognito authentication failures
resource "aws_cloudwatch_log_metric_filter" "cognito_auth_failures" {
  name           = "vclipper-cognito-auth-failures"
  log_group_name = aws_cloudwatch_log_group.cognito_logs.name
  pattern        = "[timestamp, request_id, level=\"ERROR\", message=\"*authentication failed*\" || message=\"*login failed*\" || message=\"*invalid credentials*\", ...]"

  metric_transformation {
    name      = "CognitoAuthFailures"
    namespace = "VClipper/Cognito"
    value     = "1"
    unit      = "None"
  }
}

# Metric filter for Cognito suspicious activity
resource "aws_cloudwatch_log_metric_filter" "cognito_suspicious_activity" {
  name           = "vclipper-cognito-suspicious-activity"
  log_group_name = aws_cloudwatch_log_group.cognito_logs.name
  pattern        = "[timestamp, request_id, level, message=\"*brute force*\" || message=\"*multiple failed attempts*\" || message=\"*suspicious*\", ...]"

  metric_transformation {
    name      = "CognitoSuspiciousActivity"
    namespace = "VClipper/Cognito"
    value     = "1"
    unit      = "None"
  }
}


