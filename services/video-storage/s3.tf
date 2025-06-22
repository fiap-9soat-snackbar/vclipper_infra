# Local values for bucket naming and configuration
locals {
  bucket_name = var.bucket_name_override != "" ? var.bucket_name_override : "${data.terraform_remote_state.global.outputs.project_name}-video-storage-${var.environment}"
  
  # Get frontend URLs from remote state if available, otherwise use defaults
  frontend_http_url = try(data.terraform_remote_state.frontend.outputs.frontend_hosting_config.s3_website_http_url, "")
  frontend_https_url = try(data.terraform_remote_state.frontend.outputs.frontend_hosting_config.s3_direct_https_url, "")
  
  # Combine frontend URLs with allowed origins, filtering out empty strings
  cors_origins = compact(concat(
    var.allowed_origins,
    [local.frontend_http_url, local.frontend_https_url]
  ))
  
  common_tags = merge(var.tags, {
    Service = "video-storage"
    Purpose = "Video upload and image clip storage"
  })
}

# Data source to get frontend hosting outputs
data "terraform_remote_state" "frontend" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.terraform_state_bucket
    key    = "global/frontend-hosting/terraform.tfstate"
  }
}

# S3 bucket for video storage and generated image clips
resource "aws_s3_bucket" "video_storage" {
  bucket = local.bucket_name

  tags = merge(local.common_tags, {
    Name = "VClipper Video Storage"
    Type = "Storage"
  })
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "video_storage" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.video_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 bucket public access block (security - keep this enabled)
resource "aws_s3_bucket_public_access_block" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket lifecycle configuration for automatic cleanup
resource "aws_s3_bucket_lifecycle_configuration" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  # Rule for uploaded videos (videos/ prefix)
  rule {
    id     = "video-cleanup"
    status = "Enabled"

    filter {
      prefix = "videos/"
    }

    expiration {
      days = var.video_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }

  # Rule for generated image clips (clips/ prefix)
  rule {
    id     = "clips-cleanup"
    status = "Enabled"

    filter {
      prefix = "clips/"
    }

    expiration {
      days = var.images_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }

  # Rule for temporary/processing files (temp/ prefix)
  rule {
    id     = "temp-cleanup"
    status = "Enabled"

    filter {
      prefix = "temp/"
    }

    expiration {
      days = 1
    }
  }
}

# S3 bucket CORS configuration for web uploads via pre-signed URLs
resource "aws_s3_bucket_cors_configuration" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = local.cors_origins
    expose_headers  = ["ETag", "x-amz-meta-custom-header"]
    max_age_seconds = 3000
  }
}

# S3 bucket notification configuration (placeholder for SQS integration)
resource "aws_s3_bucket_notification" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  # This will be configured later when SQS is deployed
  # The notification will trigger SQS when videos are uploaded to videos/ prefix
  depends_on = [aws_s3_bucket.video_storage]
}
