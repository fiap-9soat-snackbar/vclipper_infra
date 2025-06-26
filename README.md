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
│                        Backend Services                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐    │
│  │  Processing     │  │   VClipping     │  │   Notification  │    │
│  │   Service       │  │    Service      │  │    Service      │    │
│  │  (Video Upload) │  │ (Video Process) │  │  (Status/Email) │    │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Infrastructure Services                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐    │
│  │  SQS Processing │  │  SNS Notifications│  │  Video Storage  │    │
│  │   (Queues)      │  │   (Topics)      │  │   (S3 Buckets)  │    │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Monitoring & Observability                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐    │
│  │  CloudWatch     │  │  Log Groups     │  │  Metric Alarms  │    │
│  │  Dashboard      │  │  (12 Groups)    │  │  (21+ Alarms)   │    │
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
│   ├── video-storage/         # S3 video storage service
│   │   ├── s3.tf              # S3 buckets for video assets
│   │   ├── variables.tf       # Storage-specific variables
│   │   ├── outputs.tf         # Storage outputs
│   │   ├── backend.tf         # Backend configuration
│   │   ├── terraform.tfvars   # Service variable values
│   │   └── README.md          # Storage documentation
│   │
│   ├── sqs-processing/        # SQS message queues
│   │   ├── sqs.tf             # SQS queues and DLQ configuration
│   │   ├── variables.tf       # Queue-specific variables
│   │   ├── outputs.tf         # Queue outputs
│   │   ├── backend.tf         # Backend configuration
│   │   ├── terraform.tfvars   # Service variable values
│   │   └── README.md          # Queue documentation
│   │
│   ├── sns-notifications/     # SNS notification topics
│   │   ├── sns.tf             # SNS topics and subscriptions
│   │   ├── variables.tf       # Notification-specific variables
│   │   ├── outputs.tf         # SNS outputs
│   │   ├── backend.tf         # Backend configuration
│   │   ├── terraform.tfvars   # Service variable values
│   │   └── README.md          # Notification documentation
│   │
│   ├── monitoring/            # CloudWatch monitoring service
│   │   ├── cw-alarms.tf       # CloudWatch metric alarms (21 total)
│   │   ├── cw-dashboards.tf   # CloudWatch dashboards
│   │   ├── cw-log-groups.tf   # Log groups and metric filters
│   │   ├── data-sources.tf    # Remote state data sources
│   │   ├── locals.tf          # Local values and configurations
│   │   ├── variables.tf       # Monitoring variables
│   │   ├── outputs.tf         # Monitoring outputs
│   │   ├── backend.tf         # Backend configuration
│   │   ├── terraform.tfvars   # Service variable values
│   │   ├── dashboards/        # Dashboard JSON templates
│   │   └── README.md          # Monitoring documentation
│   │
│   └── api-gateway/           # API Gateway service
│       ├── api-gateway.tf     # HTTP & WebSocket API configuration
│       ├── variables.tf       # API Gateway variables
│       ├── outputs.tf         # API Gateway outputs
│       ├── backend.tf         # Backend configuration
│       ├── terraform.tfvars   # Service variable values
│       └── README.md          # API Gateway documentation
│
└── README.md                  # This documentation
```

## 🚀 Deployment Status

| Service | Status | Description |
|---------|--------|-------------|
| **Global** | ✅ Deployed | Shared configuration and state management |
| **Frontend Hosting** | ✅ Deployed | S3 static website hosting for React app |
| **Cognito Authentication** | ✅ Deployed | User Pool with advanced security and password history |
| **Video Storage** | ✅ Deployed | S3 buckets for video assets and processed content |
| **SQS Processing** | ✅ Deployed | Message queues for video processing workflow |
| **SNS Notifications** | ✅ Deployed | Notification topics for success/failure alerts |
| **API Gateway** | ✅ Deployed | HTTP & WebSocket APIs with JWT authentication |
| **Monitoring** | ✅ Deployed | Comprehensive CloudWatch monitoring with 21 alarms |
| **Frontend Integration** | ✅ Complete | React app successfully integrated with Cognito |
| **API Gateway Integration** | ✅ Complete | Full monitoring and logging integration |
| **Backend Services** | 🔄 Planned | Video processing microservices |

## 🛠️ Getting Started

### Prerequisites
1. **AWS CLI** configured with valid credentials
2. **Terraform v1.12+** installed
3. **LabRole** permissions in AWS educational environment

### Deployment Order

Services must be deployed in the correct order due to dependencies:

#### 1. Deploy Global Configuration
```bash
cd global/
terraform init
terraform plan
terraform apply
```

#### 2. Deploy Core Services (Independent)
```bash
# Frontend Hosting
cd services/frontend-hosting/
terraform init && terraform apply

# Cognito Authentication
cd ../cognito/
terraform init && terraform apply

# Video Storage
cd ../video-storage/
terraform init && terraform apply

# SQS Processing
cd ../sqs-processing/
terraform init && terraform apply

# SNS Notifications
cd ../sns-notifications/
terraform init && terraform apply
```

#### 3. Deploy API Gateway (Depends on Cognito + Frontend)
```bash
cd services/api-gateway/
terraform init
terraform plan
terraform apply
```

#### 4. Deploy Monitoring (Depends on all above)
```bash
cd services/monitoring/
terraform init
terraform plan
terraform apply
```
terraform apply
```

### Service Dependencies
```
Global (Required First)
├── Frontend Hosting (Independent)
├── Cognito (Independent)
├── Video Storage (Independent)
├── SQS Processing (Independent)
└── SNS Notifications (Independent)
    ├── API Gateway (Depends on Cognito + Frontend)
    └── Monitoring (Depends on all above)
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
- **HTTPS URL**: `https://vclipper-frontend-dev.s3.us-east-1.amazonaws.com/index.html`
- **Hash Routing**: Enabled for HTTPS compatibility

### Cognito Authentication
- **User Pool ID**: `us-east-1_SUMiE0yRW`
- **Client ID**: `3r2uf0r673ronu2bgdsljbjamd`
- **JWT Issuer**: `https://cognito-idp.us-east-1.amazonaws.com/us-east-1_SUMiE0yRW`
- **Advanced Security**: ENFORCED (risk-based authentication)
- **Password History**: Last 4 passwords prevented from reuse
- **Integration Status**: ✅ Live and working with React frontend

### API Gateway
- **HTTP API ID**: `7l5kskcnfl`
- **HTTP API URL**: `https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/`
- **WebSocket API ID**: `4yffht2qm0`
- **WebSocket URL**: `wss://4yffht2qm0.execute-api.us-east-1.amazonaws.com/dev`
- **JWT Authorizer ID**: `cox1ij`
- **Backend Integration**: httpbin.org (placeholder for testing)
- **CORS Configuration**: Frontend origins with credentials enabled

### Monitoring & Observability
- **Dashboard**: [VClipper Infrastructure Dashboard](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=VClipper-Infrastructure-dev)
- **Log Groups**: 12 total (AWS services + application components)
- **CloudWatch Alarms**: 21 total (infrastructure + application + API Gateway)
- **API Gateway Log Group**: `/aws/apigateway/vclipper`

## 🔗 Service Integration

### Frontend ↔ Cognito
- React app uses Cognito APIs for authentication
- JWT tokens stored in browser for API calls
- No redirects - users stay within the application

### Cognito ↔ API Gateway
- API Gateway validates JWT tokens automatically
- JWT Authorizer integrated with Cognito User Pool
- Protected routes require valid JWT tokens
- Clean separation between authentication and authorization

### API Gateway ↔ Backend Services (Future)
- Currently using httpbin.org for testing
- Ready for ECS/Lambda backend integration
- Placeholder integrations easily replaceable

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

# API Gateway
REACT_APP_API_BASE_URL=https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/
REACT_APP_WEBSOCKET_URL=wss://4yffht2qm0.execute-api.us-east-1.amazonaws.com/dev
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

### Phase 2: API Layer (✅ Complete)
- [x] API Gateway with JWT authorizer
- [x] HTTP API for REST endpoints
- [x] WebSocket API for real-time updates
- [x] CORS configuration for frontend integration
- [x] CloudWatch logging and monitoring

### Phase 3: Backend Services (🔄 Planned)
- [ ] Processing Service (video upload)
- [ ] VClipping Service (video processing)
- [ ] Notification Service (status updates)
- [ ] Replace httpbin.org placeholder integrations

### Phase 4: Advanced Features (🔄 Future)
- [ ] CloudFront distribution (if permissions allow)
- [ ] Custom domain (if Route53 available)
- [ ] Enhanced monitoring dashboards
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
cd services/api-gateway/ && terraform apply
cd services/monitoring/ && terraform apply
```

#### 3. **API Gateway Testing**
```bash
# Test health endpoint (public)
curl https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/health

# Test protected endpoint (requires JWT)
curl -H "Authorization: Bearer <JWT_TOKEN>" \
     https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/api/videos
```

#### 4. **AWS Permissions**
- Ensure LabRole has necessary permissions
- Check AWS CLI configuration: `aws sts get-caller-identity`
- Verify region setting: `aws configure get region`

### Useful Commands

```bash
# Check all service outputs
cd global/ && terraform output
cd services/frontend-hosting/ && terraform output
cd services/cognito/ && terraform output
cd services/api-gateway/ && terraform output
cd services/monitoring/ && terraform output

# Validate all configurations
find . -name "*.tf" -exec terraform validate {} \;

# Plan all services
for dir in global services/*/; do
  echo "Planning $dir"
  (cd "$dir" && terraform plan)
done
```
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
- [Video Storage](./services/video-storage/README.md)
- [SQS Processing](./services/sqs-processing/README.md)
- [SNS Notifications](./services/sns-notifications/README.md)
- [API Gateway](./services/api-gateway/README.md)
- [Monitoring Service](./services/monitoring/README.md)

## 🆘 Support

For issues and questions:
1. Check service-specific README files
2. Review troubleshooting sections
3. Verify AWS permissions and configuration
4. Check Terraform state and logs

## 📊 Current Infrastructure Summary

### ✅ **Deployed Services (8/8)**
- **Global Configuration** - Shared state and project settings
- **Frontend Hosting** - S3 static website with React app
- **Cognito Authentication** - User Pool with JWT tokens
- **Video Storage** - S3 buckets for video assets
- **SQS Processing** - Message queues for video workflow
- **SNS Notifications** - Success/failure notification topics
- **API Gateway** - HTTP & WebSocket APIs with JWT validation
- **Monitoring** - CloudWatch logs, alarms, and dashboard

### 🔗 **Live Integration Points**
- **Frontend ↔ Cognito**: Authentication working
- **Cognito ↔ API Gateway**: JWT validation active
- **API Gateway ↔ Monitoring**: Full observability enabled
- **All Services ↔ Monitoring**: Comprehensive logging and alerting

### 🚀 **Ready for Backend Services**
The infrastructure foundation is complete and ready for backend microservices deployment. API Gateway provides placeholder integrations that can be easily replaced with real backend services.
