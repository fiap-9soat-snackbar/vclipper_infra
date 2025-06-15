# VClipper Infrastructure

Terraform infrastructure as code for the VClipper video processing microservices platform, designed for educational AWS environments with LabRole constraints.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   React Frontend │    │  Cognito Auth    │    │   API Gateway       │
│   (S3 Static)   │───▶│  (JWT Tokens)    │───▶│  (JWT Validation)   │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
                                                           │
                                                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     Backend Services (Future)                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐    │
│  │  Processing     │  │   VClipping     │  │   Notification  │    │
│  │   Service       │  │    Service      │  │    Service      │    │
│  │  (Video Upload) │  │ (Video Process) │  │  (Status/Email) │    │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
vclipper_infra/
├── global/                     # Global shared configuration
│   ├── main.tf                # Global resources and data sources
│   ├── variables.tf           # Global variable definitions
│   ├── outputs.tf             # Global outputs (project name, region, etc.)
│   ├── backend.tf             # Terraform backend configuration
│   └── terraform.tfvars       # Global variable values
│
├── services/                   # Individual service configurations
│   ├── frontend-hosting/       # S3 static website hosting
│   │   ├── s3.tf              # S3 bucket and website configuration
│   │   ├── variables.tf       # Service-specific variables
│   │   ├── outputs.tf         # Service outputs
│   │   ├── backend.tf         # Backend configuration
│   │   ├── terraform.tfvars   # Service variable values
│   │   └── README.md          # Service documentation
│   │
│   ├── cognito/               # Authentication service
│   │   ├── cognito.tf         # User Pool and Client configuration
│   │   ├── variables.tf       # Authentication variables
│   │   ├── outputs.tf         # Cognito outputs (JWT config, etc.)
│   │   ├── backend.tf         # Backend configuration
│   │   ├── terraform.tfvars   # Service variable values
│   │   └── README.md          # Authentication documentation
│   │
│   └── api-gateway/           # API Gateway service (planned)
│       └── README.md          # Future API Gateway configuration
│
└── README.md                  # This documentation
```

## 🚀 Deployment Status

| Service | Status | Description |
|---------|--------|-------------|
| **Global** | ✅ Deployed | Shared configuration and state management |
| **Frontend Hosting** | ✅ Deployed | S3 static website hosting for React app |
| **Cognito Authentication** | ✅ Deployed | User Pool with API-driven authentication |
| **API Gateway** | 🔄 Planned | JWT validation and backend routing |
| **Backend Services** | 🔄 Planned | Video processing microservices |

## 🛠️ Getting Started

### Prerequisites
1. **AWS CLI** configured with valid credentials
2. **Terraform v1.12+** installed
3. **LabRole** permissions in AWS educational environment

### Initial Setup

#### 1. Deploy Global Configuration
```bash
cd global/
terraform init
terraform plan
terraform apply
```

#### 2. Deploy Frontend Hosting
```bash
cd services/frontend-hosting/
terraform init
terraform plan
terraform apply
```

#### 3. Deploy Cognito Authentication
```bash
cd services/cognito/
terraform init
terraform plan
terraform apply
```

### Service Dependencies
```
Global (Required First)
├── Frontend Hosting (Independent)
└── Cognito (Independent)
    └── API Gateway (Future - depends on Cognito)
        └── Backend Services (Future - depends on API Gateway)
```

## 🔧 Current Configuration

### Global Settings
- **Project Name**: `vclipper`
- **Environment**: `dev`
- **Region**: `us-east-1`
- **State Bucket**: `vclipper-terraform-state-dev-rmxhnjty`

### Frontend Hosting
- **S3 Bucket**: `vclipper-frontend-dev`
- **Website URL**: `http://vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com`
- **HTTPS URL**: `https://vclipper-frontend-dev.s3.us-east-1.amazonaws.com`

### Cognito Authentication
- **User Pool ID**: `us-east-1_SUMiE0yRW`
- **Client ID**: `3r2uf0r673ronu2bgdsljbjamd`
- **JWT Issuer**: `https://cognito-idp.us-east-1.amazonaws.com/us-east-1_SUMiE0yRW`

## 🔗 Service Integration

### Frontend ↔ Cognito
- React app uses Cognito APIs for authentication
- JWT tokens stored in browser for API calls
- No redirects - users stay within the application

### Cognito ↔ API Gateway (Future)
- API Gateway validates JWT tokens automatically
- Backend services use LabRole for AWS operations
- Clean separation between authentication and authorization

## 🏛️ Educational Environment Considerations

This infrastructure is designed for AWS educational environments with specific constraints:

### ✅ **What Works:**
- **LabRole**: All backend services use existing LabRole
- **S3 Static Hosting**: No complex networking required
- **Cognito User Pools**: Standard authentication service
- **API Gateway**: JWT validation without custom authorizers
- **Basic AWS Services**: EC2, S3, Lambda, etc.

### ❌ **What's Avoided:**
- **Custom IAM Roles**: Uses LabRole instead
- **CloudFront**: May require additional permissions
- **Route53**: Custom domains not needed
- **Complex VPC**: Simplified networking
- **Identity Pools**: Avoided IAM trust policy issues

## 🚀 React Application Integration

### Environment Variables
Create a `.env` file in your React project:
```bash
# AWS Configuration
REACT_APP_AWS_REGION=us-east-1

# Cognito Authentication
REACT_APP_COGNITO_USER_POOL_ID=us-east-1_SUMiE0yRW
REACT_APP_COGNITO_USER_POOL_CLIENT_ID=3r2uf0r673ronu2bgdsljbjamd

# Frontend URLs
REACT_APP_FRONTEND_URL=http://vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com

# API Gateway (when deployed)
REACT_APP_API_BASE_URL=https://your-api-gateway-url/api
```

### Deployment Script
```bash
#!/bin/bash
# deploy-frontend.sh

# Build React app
npm run build

# Deploy to S3
aws s3 sync build/ s3://vclipper-frontend-dev/ --delete

# Invalidate cache (if using CloudFront in future)
echo "Frontend deployed to: http://vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com"
```

## 🔄 Future Roadmap

### Phase 1: Foundation (✅ Complete)
- [x] Global configuration
- [x] S3 static hosting
- [x] Cognito authentication

### Phase 2: API Layer (🔄 In Progress)
- [ ] API Gateway with JWT authorizer
- [ ] Lambda functions for business logic
- [ ] S3 buckets for video storage

### Phase 3: Backend Services (🔄 Planned)
- [ ] Processing Service (video upload)
- [ ] VClipping Service (video processing)
- [ ] Notification Service (status updates)

### Phase 4: Advanced Features (🔄 Future)
- [ ] CloudFront distribution (if permissions allow)
- [ ] Custom domain (if Route53 available)
- [ ] Monitoring and logging
- [ ] CI/CD pipeline integration

## 🔧 Troubleshooting

### Common Issues

#### 1. **Terraform State Issues**
```bash
# Check state bucket access
aws s3 ls s3://vclipper-terraform-state-dev-rmxhnjty/

# Reinitialize if needed
terraform init -reconfigure
```

#### 2. **Service Dependencies**
```bash
# Deploy in correct order
cd global/ && terraform apply
cd services/frontend-hosting/ && terraform apply
cd services/cognito/ && terraform apply
```

#### 3. **AWS Permissions**
- Ensure LabRole has necessary permissions
- Check AWS CLI configuration: `aws sts get-caller-identity`
- Verify region setting: `aws configure get region`

### Useful Commands

```bash
# Check all service outputs
cd global/ && terraform output
cd services/frontend-hosting/ && terraform output
cd services/cognito/ && terraform output

# Validate all configurations
find . -name "*.tf" -exec terraform validate {} \;

# Plan all services
for dir in global services/*/; do
  echo "Planning $dir"
  (cd "$dir" && terraform plan)
done
```

## 📊 Monitoring and Costs

### Cost Optimization
- **S3**: Lifecycle policies for old versions
- **Cognito**: Free tier covers 50,000 MAUs
- **No CloudFront**: Avoiding additional costs
- **LabRole**: No custom IAM role charges

### Monitoring
- **CloudWatch**: Service logs and metrics
- **AWS Console**: Resource monitoring
- **Terraform State**: Infrastructure drift detection

## 🤝 Contributing

### Development Workflow
1. **Create feature branch**: `git checkout -b feature/new-service`
2. **Develop service**: Add new service in `services/` directory
3. **Test deployment**: Deploy to dev environment
4. **Update documentation**: Update README files
5. **Submit PR**: Include deployment instructions

### Service Standards
- Follow existing directory structure
- Include comprehensive README
- Use consistent variable naming
- Provide useful outputs for integration
- Consider educational environment constraints

## 📚 Documentation

- [Global Configuration](./global/README.md)
- [Frontend Hosting](./services/frontend-hosting/README.md)
- [Cognito Authentication](./services/cognito/README.md)
- [API Gateway](./services/api-gateway/README.md) (planned)

## 🆘 Support

For issues and questions:
1. Check service-specific README files
2. Review troubleshooting sections
3. Verify AWS permissions and configuration
4. Check Terraform state and logs
