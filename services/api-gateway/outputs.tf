#--------------------------------------------------------------
# API Gateway Outputs
#--------------------------------------------------------------

# REST API Outputs
output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.vclipper_api.id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = aws_apigatewayv2_api.vclipper_api.arn
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.vclipper_api.execution_arn
}

output "api_gateway_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.vclipper_api.api_endpoint
}

output "api_gateway_invoke_url" {
  description = "API Gateway stage invoke URL"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

# WebSocket API Outputs
output "websocket_api_id" {
  description = "ID of the WebSocket API Gateway"
  value       = aws_apigatewayv2_api.vclipper_websocket.id
}

output "websocket_api_endpoint" {
  description = "WebSocket API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.vclipper_websocket.api_endpoint
}

output "websocket_invoke_url" {
  description = "WebSocket API Gateway stage invoke URL"
  value       = aws_apigatewayv2_stage.websocket_default.invoke_url
}

# Authorizer Outputs
output "jwt_authorizer_id" {
  description = "ID of the JWT authorizer"
  value       = aws_apigatewayv2_authorizer.cognito_jwt.id
}

# Configuration for Frontend
output "frontend_api_config" {
  description = "API configuration for frontend applications"
  value = {
    api_base_url     = aws_apigatewayv2_stage.default.invoke_url
    websocket_url    = aws_apigatewayv2_stage.websocket_default.invoke_url
    api_gateway_id   = aws_apigatewayv2_api.vclipper_api.id
    region          = var.aws_region
  }
}


