# CloudWatch Alarms outputs
output "sqs_queue_depth_alarm_name" {
  description = "Name of the SQS queue depth alarm"
  value       = aws_cloudwatch_metric_alarm.sqs_queue_depth.alarm_name
}

output "sqs_dlq_messages_alarm_name" {
  description = "Name of the SQS DLQ messages alarm"
  value       = aws_cloudwatch_metric_alarm.sqs_dlq_messages.alarm_name
}

output "sqs_message_age_alarm_name" {
  description = "Name of the SQS message age alarm"
  value       = aws_cloudwatch_metric_alarm.sqs_message_age.alarm_name
}

output "s3_video_bucket_size_alarm_name" {
  description = "Name of the S3 video storage bucket size alarm"
  value       = aws_cloudwatch_metric_alarm.s3_video_bucket_size.alarm_name
}

output "s3_video_request_rate_alarm_name" {
  description = "Name of the S3 video storage request rate alarm"
  value       = aws_cloudwatch_metric_alarm.s3_video_request_rate.alarm_name
}

# S3 Frontend Hosting Alarms
output "s3_frontend_bucket_size_alarm_name" {
  description = "Name of the S3 frontend bucket size alarm"
  value       = aws_cloudwatch_metric_alarm.s3_frontend_bucket_size.alarm_name
}

output "s3_frontend_request_rate_alarm_name" {
  description = "Name of the S3 frontend request rate alarm"
  value       = aws_cloudwatch_metric_alarm.s3_frontend_request_rate.alarm_name
}

output "s3_frontend_4xx_errors_alarm_name" {
  description = "Name of the S3 frontend 4xx errors alarm"
  value       = aws_cloudwatch_metric_alarm.s3_frontend_4xx_errors.alarm_name
}

# Cognito Alarms
output "cognito_signin_failures_alarm_name" {
  description = "Name of the Cognito sign-in failures alarm"
  value       = aws_cloudwatch_metric_alarm.cognito_signin_failures.alarm_name
}

output "cognito_token_refresh_failures_alarm_name" {
  description = "Name of the Cognito token refresh failures alarm"
  value       = aws_cloudwatch_metric_alarm.cognito_token_refresh_failures.alarm_name
}

output "sns_success_delivery_failures_alarm_name" {
  description = "Name of the SNS success topic delivery failures alarm"
  value       = aws_cloudwatch_metric_alarm.sns_success_delivery_failures.alarm_name
}

output "sns_failure_delivery_failures_alarm_name" {
  description = "Name of the SNS failure topic delivery failures alarm"
  value       = aws_cloudwatch_metric_alarm.sns_failure_delivery_failures.alarm_name
}

output "sns_failure_high_volume_alarm_name" {
  description = "Name of the SNS failure topic high volume alarm"
  value       = aws_cloudwatch_metric_alarm.sns_failure_high_volume.alarm_name
}

# CloudWatch Log Groups outputs
output "app_processing_log_group_name" {
  description = "Name of the application processing log group"
  value       = aws_cloudwatch_log_group.app_processing_logs.name
}

output "app_frontend_log_group_name" {
  description = "Name of the application frontend log group"
  value       = aws_cloudwatch_log_group.app_frontend_logs.name
}

output "app_clipping_log_group_name" {
  description = "Name of the application clipping log group"
  value       = aws_cloudwatch_log_group.app_clipping_logs.name
}

output "app_user_log_group_name" {
  description = "Name of the application user service log group"
  value       = aws_cloudwatch_log_group.app_user_logs.name
}


output "lambda_authorizer_log_group_name" {
  description = "Name of the Lambda authorizer log group"
  value       = aws_cloudwatch_log_group.lambda_authorizer_logs.name
}

output "eks_cluster_log_group_name" {
  description = "Name of the EKS cluster log group"
  value       = aws_cloudwatch_log_group.eks_cluster_logs.name
}

output "s3_frontend_access_log_group_name" {
  description = "Name of the S3 frontend access log group"
  value       = aws_cloudwatch_log_group.s3_frontend_access_logs.name
}

output "s3_video_storage_log_group_name" {
  description = "Name of the S3 video storage log group"
  value       = aws_cloudwatch_log_group.s3_video_storage_logs.name
}

output "sqs_log_group_name" {
  description = "Name of the SQS log group"
  value       = aws_cloudwatch_log_group.sqs_logs.name
}

output "sns_log_group_name" {
  description = "Name of the SNS log group"
  value       = aws_cloudwatch_log_group.sns_logs.name
}

output "cognito_log_group_name" {
  description = "Name of the Cognito log group"
  value       = aws_cloudwatch_log_group.cognito_logs.name
}

# CloudWatch Dashboard outputs
output "infrastructure_dashboard_name" {
  description = "Name of the infrastructure CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.vclipper_infrastructure.dashboard_name
}

output "infrastructure_dashboard_url" {
  description = "URL to access the infrastructure CloudWatch dashboard"
  value       = "https://${data.terraform_remote_state.global.outputs.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${data.terraform_remote_state.global.outputs.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.vclipper_infrastructure.dashboard_name}"
}

# Custom Metric Alarms outputs
output "application_error_rate_alarm_name" {
  description = "Name of the application error rate alarm"
  value       = aws_cloudwatch_metric_alarm.application_error_rate.alarm_name
}

output "video_processing_failure_rate_alarm_name" {
  description = "Name of the video processing failure rate alarm"
  value       = aws_cloudwatch_metric_alarm.video_processing_failure_rate.alarm_name
}

# Monitoring configuration for applications
output "monitoring_config" {
  description = "Complete monitoring configuration for application integration"
  value = {
    log_groups = {
      eks_cluster_logs         = aws_cloudwatch_log_group.eks_cluster_logs.name
      lambda_authorizer_logs   = aws_cloudwatch_log_group.lambda_authorizer_logs.name
      s3_frontend_access_logs  = aws_cloudwatch_log_group.s3_frontend_access_logs.name
      s3_video_storage_logs    = aws_cloudwatch_log_group.s3_video_storage_logs.name
      sqs_logs                 = aws_cloudwatch_log_group.sqs_logs.name
      sns_logs                 = aws_cloudwatch_log_group.sns_logs.name
      cognito_logs             = aws_cloudwatch_log_group.cognito_logs.name
      app_frontend_logs        = aws_cloudwatch_log_group.app_frontend_logs.name
      app_processing_logs      = aws_cloudwatch_log_group.app_processing_logs.name
      app_clipping_logs        = aws_cloudwatch_log_group.app_clipping_logs.name
      app_user_logs            = aws_cloudwatch_log_group.app_user_logs.name
    }
    dashboards = {
      infrastructure_dashboard_name = aws_cloudwatch_dashboard.vclipper_infrastructure.dashboard_name
      infrastructure_dashboard_url  = "https://${data.terraform_remote_state.global.outputs.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${data.terraform_remote_state.global.outputs.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.vclipper_infrastructure.dashboard_name}"
    }
    alarms = {
      sqs_queue_depth_alarm         = aws_cloudwatch_metric_alarm.sqs_queue_depth.alarm_name
      sqs_dlq_messages_alarm        = aws_cloudwatch_metric_alarm.sqs_dlq_messages.alarm_name
      s3_video_bucket_size_alarm    = aws_cloudwatch_metric_alarm.s3_video_bucket_size.alarm_name
      s3_frontend_bucket_size_alarm = aws_cloudwatch_metric_alarm.s3_frontend_bucket_size.alarm_name
      application_error_alarm       = aws_cloudwatch_metric_alarm.application_error_rate.alarm_name
      cognito_signin_failures_alarm = aws_cloudwatch_metric_alarm.cognito_signin_failures.alarm_name
    }
  }
  sensitive = false
}

