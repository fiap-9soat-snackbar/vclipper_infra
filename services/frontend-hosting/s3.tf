#--------------------------------------------------------------
# S3 Bucket for Frontend Static Files (Public Access for CloudFront)
#--------------------------------------------------------------

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = var.bucket_name_override != "" ? var.bucket_name_override : "${data.terraform_remote_state.global.outputs.project_name}-frontend-${data.terraform_remote_state.global.outputs.environment}"

  tags = merge(
    {
      Name        = var.bucket_name_override != "" ? var.bucket_name_override : "${data.terraform_remote_state.global.outputs.project_name}-frontend-${data.terraform_remote_state.global.outputs.environment}"
      Project     = data.terraform_remote_state.global.outputs.project_name
      Environment = data.terraform_remote_state.global.outputs.environment
      Purpose     = "frontend-static-files"
    },
    var.tags
  )
}

#--------------------------------------------------------------
# S3 Static Website Configuration (Public Access for CloudFront)
#--------------------------------------------------------------

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"  # SPA routing support
  }
}

# Allow public read access for CloudFront (and direct access)
resource "aws_s3_bucket_public_access_block" "frontend_bucket_pab" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false  # Allow public ACLs for website hosting
  block_public_policy     = false  # Allow public bucket policy
  ignore_public_acls      = false  # Don't ignore public ACLs
  restrict_public_buckets = false  # Allow public bucket
}

# S3 Bucket Policy - Improved: Allow Website Endpoint + Secure Management
#--------------------------------------------------------------

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      },
      {
        Sid       = "DenyInsecureManagementOperations"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutBucketPolicy",
          "s3:DeleteBucket",
          "s3:PutBucketAcl",
          "s3:PutObjectAcl"
        ]
        Resource = [
          aws_s3_bucket.frontend_bucket.arn,
          "${aws_s3_bucket.frontend_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend_bucket_pab]
}

#--------------------------------------------------------------
# S3 Bucket Configuration
#--------------------------------------------------------------

# Enable versioning for file history
resource "aws_s3_bucket_versioning" "frontend_bucket_versioning" {
  bucket = aws_s3_bucket.frontend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_bucket_encryption" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CORS configuration for API calls
resource "aws_s3_bucket_cors_configuration" "frontend_bucket_cors" {
  bucket = aws_s3_bucket.frontend_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = var.allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Lifecycle configuration for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "frontend_bucket_lifecycle" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    id     = "delete_old_versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = var.old_version_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
