# VClipper Frontend Hosting Infrastructure

This Terraform configuration provisions AWS S3 static website hosting for the VClipper React frontend application, with a clear migration path to Application Load Balancer (ALB) when backend services are ready.

## 🚀 Features

- **Private S3 Bucket**: Secure storage for React build files with controlled public access
- **Static Website Hosting**: S3 website endpoint with SPA routing support
- **Dual Access Methods**: Both HTTP website endpoint and HTTPS direct access
- **Security First**: HTTPS-only enforcement for management operations
- **Cost Optimization**: Lifecycle policies and efficient storage settings
- **Migration Ready**: Prepared for ALB integration when backend is deployed

## 📐 Current Architecture (Phase 1)

```
Users → S3 Static Website Hosting
├── HTTP: vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com
└── HTTPS: vclipper-frontend-dev.s3.us-east-1.amazonaws.com
```

## 🛠️ Project Structure

```
.
├── s3.tf                   # S3 bucket configuration and security
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output value definitions
├── backend.tf              # Terraform backend and provider configuration
├── terraform.tfvars        # Variable values (gitignored)
└── README.md               # This documentation
```

## 🛠️ Terraform Resources

| Resource Type | Purpose |
|---------------|---------|
| `aws_s3_bucket` | Creates the S3 bucket for frontend files |
| `aws_s3_bucket_website_configuration` | Enables static website hosting |
| `aws_s3_bucket_versioning` | Enables versioning for file history |
| `aws_s3_bucket_server_side_encryption_configuration` | Encrypts stored files |
| `aws_s3_bucket_public_access_block` | Allows controlled public access |
| `aws_s3_bucket_cors_configuration` | Configures CORS for API calls |
| `aws_s3_bucket_lifecycle_configuration` | Manages old version cleanup |
| `aws_s3_bucket_policy` | Improved policy allowing website endpoint + securing management |

## 🚀 Deployment

### Prerequisites
1. **AWS CLI Configured** with valid credentials
2. **Terraform v1.12+** installed
3. **Global Terraform State** deployed (for project name and region)

### Configuration Variables
- `environment`: Environment name (default: "dev")
- `allowed_origins`: CORS allowed origins (default: ["*"])
- `old_version_retention_days`: Days to retain old versions (default: 30)

## 🛠️ How to Run Terraform

### One-time Initialization (Required for new developers)
Before running plan/apply for the first time, initialize the backend:
```bash
terraform init -backend-config="bucket=$(grep bucket terraform.tfvars | cut -d'=' -f2 | tr -d ' "')"
```

### Regular Operations
After initialization, you can run normal Terraform commands:
```bash
# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy resources (if needed)
terraform destroy
```

**Note:** The `terraform.tfvars` file contains the state bucket name and is automatically used by Terraform.

## 🌐 Access URLs

After deployment, your frontend will be accessible via:

- **HTTP Website Endpoint**: `http://vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com`
- **HTTPS Direct Access**: `https://vclipper-frontend-dev.s3.us-east-1.amazonaws.com/index.html`

## 🔒 Security Policy

The improved S3 bucket policy provides:

### ✅ **Allowed Operations:**
- **Public read access** (`s3:GetObject`) - for serving static files
- **HTTP website endpoint** - for static hosting functionality
- **HTTPS direct access** - for secure file access

### 🔒 **Secured Operations (HTTPS Required):**
- File uploads (`s3:PutObject`)
- File deletions (`s3:DeleteObject`)
- Policy changes (`s3:PutBucketPolicy`)
- Bucket deletion (`s3:DeleteBucket`)
- ACL modifications (`s3:PutBucketAcl`, `s3:PutObjectAcl`)

## 🔗 Integration with Cognito Authentication

This frontend hosting service is integrated with the VClipper Cognito authentication service:

### Authentication Flow
```
React App (S3) → Cognito APIs → JWT Tokens → API Gateway → Backend Services
```

### Cognito Integration URLs
The S3 website URLs are configured as valid origins in the Cognito service:
- **HTTP Website**: `http://vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com`
- **HTTPS Direct**: `https://vclipper-frontend-dev.s3.us-east-1.amazonaws.com`

### React Environment Variables
Your React app should include these Cognito environment variables:
```bash
# Cognito Configuration (from cognito service outputs)
REACT_APP_AWS_REGION=us-east-1
REACT_APP_COGNITO_USER_POOL_ID=us-east-1_SUMiE0yRW
REACT_APP_COGNITO_USER_POOL_CLIENT_ID=3r2uf0r673ronu2bgdsljbjamd

# Frontend URLs (from this service outputs)
REACT_APP_FRONTEND_URL=http://vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com
```

## 🚀 React Application Deployment

### Build and Deploy
```bash
# In your React project directory
npm run build

# Upload build files to S3
aws s3 sync build/ s3://vclipper-frontend-dev/ --delete

# Access your application
open http://vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com
```

### React Configuration
Update your `package.json` for proper asset paths:
```json
{
  "homepage": "http://vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com"
}
```

## 🔄 Migration Path to ALB + Backend Integration

### Phase 2: Application Load Balancer (When Backend Ready)

When EKS backend services are deployed, migrate to ALB architecture:

```
Users (HTTPS) → ALB + SSL Certificate → Path-based Routing
├── / → S3 Website Endpoint (Frontend)
└── /api/* → EKS Services (Backend)
```

### Migration Steps:

#### 1. **Create VPC Infrastructure**
```hcl
# Add to new alb.tf file
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
```

#### 2. **Deploy Application Load Balancer**
```hcl
resource "aws_lb" "main" {
  name               = "vclipper-main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}
```

#### 3. **Configure Path-based Routing**
```hcl
# Frontend routing
resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100
  
  action {
    type = "redirect"
    redirect {
      host = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
      port = "80"
      protocol = "HTTP"
      status_code = "HTTP_302"
    }
  }
  
  condition {
    path_pattern { values = ["/", "/static/*"] }
  }
}

# Backend API routing
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 200
  
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.eks_api.arn
  }
  
  condition {
    path_pattern { values = ["/api/*"] }
  }
}
```

#### 4. **Update React Configuration**
```json
{
  "homepage": "https://your-alb-domain.us-east-1.elb.amazonaws.com"
}
```

### Migration Benefits:
- ✅ **Single HTTPS endpoint** for frontend and backend
- ✅ **Custom SSL certificate** support
- ✅ **Unified domain** for all services
- ✅ **Health checks** and monitoring
- ✅ **Scalable architecture** for production

### Migration Timeline:
1. **Phase 1 (Current)**: S3 static hosting ✅
2. **Phase 2 (Backend Ready)**: Add ALB + path routing
3. **Phase 3 (Future)**: CloudFront + custom domain (when permissions available)

## 📊 Outputs

Key outputs for integration with other services:
- `bucket_name`: S3 bucket name for deployment scripts
- `bucket_website_endpoint`: HTTP website URL
- `frontend_hosting_config`: Complete configuration object with all URLs

## 🔧 Troubleshooting

### Common Issues:
1. **Access Denied**: Ensure files are uploaded to S3 bucket
2. **404 Errors**: Check SPA routing configuration
3. **CORS Issues**: Verify `allowed_origins` variable

### Useful Commands:
```bash
# Check bucket contents
aws s3 ls s3://vclipper-frontend-dev/

# Test website endpoint
curl -I http://vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com

# Test HTTPS access
curl -I https://vclipper-frontend-dev.s3.us-east-1.amazonaws.com/index.html
```
