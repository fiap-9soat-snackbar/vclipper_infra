output "bucket_name" {
  description = "Name of the S3 bucket for frontend static files"
  value       = aws_s3_bucket.frontend_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket for frontend static files"
  value       = aws_s3_bucket.frontend_bucket.arn
}

output "bucket_id" {
  description = "ID of the S3 bucket for frontend static files"
  value       = aws_s3_bucket.frontend_bucket.id
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.frontend_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
}

output "bucket_website_endpoint" {
  description = "S3 bucket website endpoint"
  value       = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
}

output "bucket_website_domain" {
  description = "S3 bucket website domain"
  value       = aws_s3_bucket_website_configuration.frontend_website.website_domain
}

# Useful for other services that need to reference this infrastructure
output "frontend_hosting_config" {
  description = "Complete frontend hosting configuration"
  value = {
    s3_bucket_name             = aws_s3_bucket.frontend_bucket.bucket
    s3_bucket_arn              = aws_s3_bucket.frontend_bucket.arn
    s3_website_endpoint        = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
    s3_direct_https_url        = "https://${aws_s3_bucket.frontend_bucket.bucket_regional_domain_name}"
    s3_website_http_url        = "http://${aws_s3_bucket_website_configuration.frontend_website.website_endpoint}"
  }
}
