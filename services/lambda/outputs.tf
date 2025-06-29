output "lambda_authorizer_invoke_arn" {
  description = "Invoke ARN do Lambda Authorizer"
  value       = aws_lambda_function.authorizer.invoke_arn
}

output "aws_lambda_function_name" {
  description = "AWS Function Name"
  value       = aws_lambda_function.authorizer.function_name
}