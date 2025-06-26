#--------------------------------------------------------------
# VClipper API Gateway - Video Processing REST API
#--------------------------------------------------------------

# Data sources for remote state
data "terraform_remote_state" "cognito" {
  backend = "s3"
  config = {
    region = var.aws_region
    bucket = var.terraform_state_bucket
    key    = "global/cognito/terraform.tfstate"
  }
}

data "terraform_remote_state" "frontend_hosting" {
  backend = "s3"
  config = {
    region = var.aws_region
    bucket = var.terraform_state_bucket
    key    = "global/frontend-hosting/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}

#--------------------------------------------------------------
# API Gateway HTTP API
#--------------------------------------------------------------

resource "aws_apigatewayv2_api" "vclipper_api" {
  name          = "${var.project_name}-${var.environment}-api"
  description   = "VClipper Video Processing HTTP API Gateway"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_credentials = true
    allow_headers     = var.cors_allow_headers
    allow_methods     = var.cors_allow_methods
    allow_origins     = [
      data.terraform_remote_state.frontend_hosting.outputs.frontend_hosting_config.s3_website_http_url,
      data.terraform_remote_state.frontend_hosting.outputs.frontend_hosting_config.s3_direct_https_url
    ]
    expose_headers    = ["date", "keep-alive"]
    max_age          = 86400
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-api"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Service     = "api-gateway"
  }
}

#--------------------------------------------------------------
# JWT Authorizer (Cognito Integration)
#--------------------------------------------------------------

resource "aws_apigatewayv2_authorizer" "cognito_jwt" {
  api_id           = aws_apigatewayv2_api.vclipper_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-jwt-authorizer"

  jwt_configuration {
    audience = [data.terraform_remote_state.cognito.outputs.user_pool_client_id]
    issuer   = data.terraform_remote_state.cognito.outputs.cognito_config.jwt_configuration.issuer
  }
}



#--------------------------------------------------------------
# API Gateway Stage
#--------------------------------------------------------------

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.vclipper_api.id
  name        = "$default"
  auto_deploy = true
  
  # Access logging to monitoring service log group
  access_log_settings {
    destination_arn = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/apigateway/vclipper"
    format = jsonencode({
      requestId        = "$context.requestId"
      ip              = "$context.identity.sourceIp"
      requestTime     = "$context.requestTime"
      httpMethod      = "$context.httpMethod"
      routeKey        = "$context.routeKey"
      status          = "$context.status"
      protocol        = "$context.protocol"
      responseLength  = "$context.responseLength"
      error           = "$context.error.message"
      integrationError = "$context.integration.error"
    })
  }
  
  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit   = var.throttling_burst_limit
    throttling_rate_limit    = var.throttling_rate_limit
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-api-stage"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Service     = "api-gateway"
  }
}

#--------------------------------------------------------------
# Health Check Endpoint (No Auth Required)
#--------------------------------------------------------------

resource "aws_apigatewayv2_integration" "health_check" {
  api_id           = aws_apigatewayv2_api.vclipper_api.id
  integration_type = "HTTP_PROXY"
  integration_method = "GET"
  # integration_uri  = "http://${var.backend_alb_dns_name}/actuator/health"  # TODO: Update when backend is deployed
  integration_uri  = "https://${var.backend_alb_dns_name}/status/200"  # Using httpbin.org for testing
  
  request_parameters = {
    "overwrite:header.Host" = var.backend_alb_dns_name
  }
}

resource "aws_apigatewayv2_route" "health_check" {
  api_id    = aws_apigatewayv2_api.vclipper_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.health_check.id}"
}

#--------------------------------------------------------------
# Video Processing Endpoints
#--------------------------------------------------------------

# Video Upload (Multipart form data)
resource "aws_apigatewayv2_integration" "video_upload" {
  api_id           = aws_apigatewayv2_api.vclipper_api.id
  integration_type = "HTTP_PROXY"
  integration_method = "POST"
  # integration_uri  = "http://${var.backend_alb_dns_name}/api/videos/upload"  # TODO: Update when backend is deployed
  integration_uri  = "https://${var.backend_alb_dns_name}/post"  # Using httpbin.org for testing
  
  request_parameters = {
    "overwrite:header.Host" = var.backend_alb_dns_name
  }
  
  # Increase timeout for file uploads
  timeout_milliseconds = 29000
}

resource "aws_apigatewayv2_route" "video_upload" {
  api_id    = aws_apigatewayv2_api.vclipper_api.id
  route_key = "POST /api/videos/upload"
  target    = "integrations/${aws_apigatewayv2_integration.video_upload.id}"
  
  authorization_type = "JWT"
  authorizer_id     = aws_apigatewayv2_authorizer.cognito_jwt.id
}

# Get Video Processing Status
resource "aws_apigatewayv2_integration" "video_status" {
  api_id           = aws_apigatewayv2_api.vclipper_api.id
  integration_type = "HTTP_PROXY"
  integration_method = "GET"
  # integration_uri  = "http://${var.backend_alb_dns_name}/api/videos/{videoId}/status"  # TODO: Update when backend is deployed
  integration_uri  = "https://${var.backend_alb_dns_name}/get"  # Using httpbin.org for testing
  
  request_parameters = {
    "overwrite:header.Host" = var.backend_alb_dns_name
  }
}

resource "aws_apigatewayv2_route" "video_status" {
  api_id    = aws_apigatewayv2_api.vclipper_api.id
  route_key = "GET /api/videos/{videoId}/status"
  target    = "integrations/${aws_apigatewayv2_integration.video_status.id}"
  
  authorization_type = "JWT"
  authorizer_id     = aws_apigatewayv2_authorizer.cognito_jwt.id
}

# List User Videos
resource "aws_apigatewayv2_integration" "list_videos" {
  api_id           = aws_apigatewayv2_api.vclipper_api.id
  integration_type = "HTTP_PROXY"
  integration_method = "GET"
  # integration_uri  = "http://${var.backend_alb_dns_name}/api/videos"  # TODO: Update when backend is deployed
  integration_uri  = "https://${var.backend_alb_dns_name}/get"  # Using httpbin.org for testing
  
  request_parameters = {
    "overwrite:header.Host" = var.backend_alb_dns_name
  }
}

resource "aws_apigatewayv2_route" "list_videos" {
  api_id    = aws_apigatewayv2_api.vclipper_api.id
  route_key = "GET /api/videos"
  target    = "integrations/${aws_apigatewayv2_integration.list_videos.id}"
  
  authorization_type = "JWT"
  authorizer_id     = aws_apigatewayv2_authorizer.cognito_jwt.id
}

# Get Video Download URL (Future endpoint)
resource "aws_apigatewayv2_integration" "video_download" {
  api_id           = aws_apigatewayv2_api.vclipper_api.id
  integration_type = "HTTP_PROXY"
  integration_method = "GET"
  # integration_uri  = "http://${var.backend_alb_dns_name}/api/videos/{videoId}/download"  # TODO: Update when backend is deployed
  integration_uri  = "https://${var.backend_alb_dns_name}/get"  # Using httpbin.org for testing
  
  request_parameters = {
    "overwrite:header.Host" = var.backend_alb_dns_name
  }
}

resource "aws_apigatewayv2_route" "video_download" {
  api_id    = aws_apigatewayv2_api.vclipper_api.id
  route_key = "GET /api/videos/{videoId}/download"
  target    = "integrations/${aws_apigatewayv2_integration.video_download.id}"
  
  authorization_type = "JWT"
  authorizer_id     = aws_apigatewayv2_authorizer.cognito_jwt.id
}

#--------------------------------------------------------------
# WebSocket API for Real-time Updates (Future)
#--------------------------------------------------------------

resource "aws_apigatewayv2_api" "vclipper_websocket" {
  name          = "${var.project_name}-${var.environment}-websocket"
  description   = "VClipper WebSocket API for real-time video processing updates"
  protocol_type = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-websocket"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Service     = "api-gateway"
    Component   = "websocket"
  }
}

# WebSocket Stage
resource "aws_apigatewayv2_stage" "websocket_default" {
  api_id      = aws_apigatewayv2_api.vclipper_websocket.id
  name        = "dev"
  auto_deploy = true
  
  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit   = var.throttling_burst_limit
    throttling_rate_limit    = var.throttling_rate_limit
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-websocket-stage"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Service     = "api-gateway"
    Component   = "websocket"
  }
}

# WebSocket Routes (Placeholder for future implementation)
resource "aws_apigatewayv2_route" "websocket_connect" {
  api_id    = aws_apigatewayv2_api.vclipper_websocket.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.websocket_placeholder.id}"
}

resource "aws_apigatewayv2_route" "websocket_disconnect" {
  api_id    = aws_apigatewayv2_api.vclipper_websocket.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.websocket_placeholder.id}"
}

# Placeholder integration (will be replaced with Lambda functions)
resource "aws_apigatewayv2_integration" "websocket_placeholder" {
  api_id           = aws_apigatewayv2_api.vclipper_websocket.id
  integration_type = "MOCK"
  
  # Simple mock response for WebSocket
  passthrough_behavior = "WHEN_NO_MATCH"
}
