#--------------------------------------------------------------
# CloudWatch Dashboard
#--------------------------------------------------------------

resource "aws_cloudwatch_dashboard" "vclipper_infrastructure" {
  dashboard_name = "VClipper-Infrastructure-${data.terraform_remote_state.global.outputs.environment}"

  dashboard_body = templatefile("${path.module}/dashboards/infrastructure_dashboard.json", {
    aws_region               = data.terraform_remote_state.global.outputs.aws_region
    queue_name              = data.terraform_remote_state.sqs.outputs.queue_name
    dlq_name                = data.terraform_remote_state.sqs.outputs.dlq_name
    s3_video_bucket_name    = data.terraform_remote_state.video_storage.outputs.bucket_name
    s3_frontend_bucket_name = data.terraform_remote_state.frontend_hosting.outputs.bucket_name
    success_topic_name      = data.terraform_remote_state.sns_notifications.outputs.success_topic_name
    failure_topic_name      = data.terraform_remote_state.sns_notifications.outputs.failure_topic_name
    cognito_user_pool_id    = data.terraform_remote_state.cognito.outputs.user_pool_id
    cognito_client_id       = data.terraform_remote_state.cognito.outputs.user_pool_client_id
    application_log_group   = aws_cloudwatch_log_group.app_processing_logs.name
    api_gateway_id          = data.terraform_remote_state.api_gateway.outputs.api_gateway_id
    websocket_api_id        = data.terraform_remote_state.api_gateway.outputs.websocket_api_id
  })
}
