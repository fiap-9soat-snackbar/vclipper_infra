# S3 bucket outputs
output "bucket_name" {
  description = "Name of the video storage S3 bucket"
  value       = aws_s3_bucket.video_storage.bucket
}

output "bucket_arn" {
  description = "ARN of the video storage S3 bucket"
  value       = aws_s3_bucket.video_storage.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.video_storage.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.video_storage.bucket_regional_domain_name
}

# Configuration outputs for applications
output "video_prefix" {
  description = "S3 prefix for uploaded videos"
  value       = "videos/"
}

output "clips_prefix" {
  description = "S3 prefix for generated image clips"
  value       = "clips/"
}

output "temp_prefix" {
  description = "S3 prefix for temporary processing files"
  value       = "temp/"
}

output "presigned_url_expiration" {
  description = "Default expiration time for pre-signed URLs in seconds"
  value       = var.presigned_url_expiration
}

output "max_video_size_mb" {
  description = "Maximum allowed video file size in MB"
  value       = var.max_video_size_mb
}

output "allowed_video_types" {
  description = "List of allowed video MIME types"
  value       = var.allowed_video_types
}

# Integration outputs
output "cors_origins" {
  description = "List of allowed CORS origins"
  value       = local.cors_origins
  sensitive   = false
}

# Lifecycle configuration outputs
output "video_retention_days" {
  description = "Number of days videos are retained"
  value       = var.video_retention_days
}

output "images_retention_days" {
  description = "Number of days image clips are retained"
  value       = var.images_retention_days
}
