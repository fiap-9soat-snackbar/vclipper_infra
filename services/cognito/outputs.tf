output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Endpoint name of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.endpoint
}

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.main.id
}

output "user_pool_client_secret" {
  description = "Secret of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.main.client_secret
  sensitive   = true
}

# Configuration object for other services
output "cognito_config" {
  description = "Complete Cognito configuration for other services"
  value = {
    user_pool_id     = aws_cognito_user_pool.main.id
    user_pool_arn    = aws_cognito_user_pool.main.arn
    app_client_id    = aws_cognito_user_pool_client.main.id
    region           = data.terraform_remote_state.global.outputs.aws_region
    
    # JWT configuration for API Gateway
    jwt_configuration = {
      issuer   = "https://cognito-idp.${data.terraform_remote_state.global.outputs.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
      audience = aws_cognito_user_pool_client.main.id
    }
  }
}

# Frontend environment variables
output "frontend_env_vars" {
  description = "Environment variables for frontend application"
  value = {
    REACT_APP_AWS_REGION                = data.terraform_remote_state.global.outputs.aws_region
    REACT_APP_COGNITO_USER_POOL_ID      = aws_cognito_user_pool.main.id
    REACT_APP_COGNITO_USER_POOL_CLIENT_ID = aws_cognito_user_pool_client.main.id
  }
}
