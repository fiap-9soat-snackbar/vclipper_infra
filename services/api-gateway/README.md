# VClipper API Gateway Infrastructure

This Terraform configuration provisions AWS API Gateway resources for the VClipper video processing platform, providing REST API endpoints with Cognito JWT authentication and WebSocket API for real-time updates.

## 🚀 Features

- **HTTP API Gateway**: RESTful endpoints for video processing operations
- **JWT Authentication**: Cognito User Pool integration with automatic token validation
- **WebSocket API**: Real-time status updates for video processing (future implementation)
- **CORS Configuration**: Cross-origin resource sharing for frontend integration
- **CloudWatch Logging**: Comprehensive request/response logging and monitoring
- **Rate Limiting**: Throttling protection with configurable burst and rate limits

## 📐 Current Architecture

```
React Frontend → API Gateway (JWT Auth) → Backend Services (ALB)
     ↓              ↓                        ↓
Cognito JWT → JWT Authorizer → Video Processing APIs
     ↓              ↓                        ↓
WebSocket API → Real-time Updates → Status Notifications
```

## 🛠️ Project Structure

```
.
├── api-gateway.tf          # API Gateway, authorizer, and route configurations
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output value definitions
├── backend.tf              # Terraform backend and provider configuration
├── terraform.tfvars        # Variable values (gitignored)
└── README.md               # This documentation
```

## 🛠️ Terraform Resources

| Resource Type | Purpose |
|---------------|---------|
| `aws_apigatewayv2_api` | Creates HTTP and WebSocket API Gateways |
| `aws_apigatewayv2_authorizer` | Configures JWT authorizer with Cognito |
| `aws_apigatewayv2_stage` | Creates deployment stages with logging |
| `aws_apigatewayv2_route` | Defines API routes and integrations |
| `aws_apigatewayv2_integration` | Backend service integrations |
| `aws_cloudwatch_log_group` | API Gateway access logs |

## 🚀 Deployment

### Prerequisites
1. **AWS CLI Configured** with valid credentials
2. **Terraform v1.12+** installed
3. **Global Terraform State** deployed (for project configuration)
4. **Cognito Service** deployed (for JWT authorizer configuration)
5. **Frontend Hosting Service** deployed (for CORS configuration)

### Configuration Variables
- `project_name`: Project name (default: "vclipper")
- `environment`: Environment name (default: "dev")
- `backend_alb_dns_name`: Backend ALB DNS name (currently: "httpbin.org" for testing)
- `throttling_burst_limit`: API throttling burst limit (default: 100)
- `throttling_rate_limit`: API throttling rate limit (default: 50)

### Deploy API Gateway
```bash
cd services/api-gateway/
terraform init
terraform plan
terraform apply
```

### Verify Deployment
```bash
# Test health endpoint (no auth required)
curl https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/health

# Test authenticated endpoint (requires JWT token)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/api/videos
```

## ✅ Current Deployment Status

| Component | Status | Details |
|-----------|--------|---------|
| **HTTP API Gateway** | ✅ Deployed | ID: `7l5kskcnfl` |
| **WebSocket API** | ✅ Deployed | ID: `4yffht2qm0` |
| **JWT Authorizer** | ✅ Deployed | ID: `cox1ij` |
| **CORS Configuration** | ✅ Deployed | Frontend origins configured |
| **Access Logging** | ✅ Deployed | Integrated with monitoring service |
| **Placeholder Integrations** | ✅ Deployed | Using httpbin.org for testing |
| **CloudWatch Monitoring** | ✅ Deployed | 6 alarms + dashboard widgets |

### Live Endpoints
- **HTTP API URL**: `https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/`
- **WebSocket URL**: `wss://4yffht2qm0.execute-api.us-east-1.amazonaws.com/dev`
- **Dashboard**: [VClipper Infrastructure Dashboard](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=VClipper-Infrastructure-dev)

## 📋 API Endpoints

### REST API Routes

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| `GET` | `/health` | Backend health check | ❌ No |
| `POST` | `/api/videos/upload` | Upload video for processing | ✅ JWT |
| `GET` | `/api/videos/{videoId}/status` | Get processing status | ✅ JWT |
| `GET` | `/api/videos` | List user's videos | ✅ JWT |
| `GET` | `/api/videos/{videoId}/download` | Get download URL | ✅ JWT |

### WebSocket API (Future Implementation)
- **Connection URL**: `wss://YOUR_WS_ID.execute-api.us-east-1.amazonaws.com/dev`
- **Events**: Video processing status updates
- **Authentication**: JWT token validation on connection

## 🔐 Security Configuration

### JWT Authentication
- **Issuer**: Cognito User Pool (`https://cognito-idp.us-east-1.amazonaws.com/us-east-1_XXXXXXXXX`)
- **Audience**: Cognito App Client ID
- **Token Location**: `Authorization: Bearer <token>` header
- **Algorithm**: RS256 (Cognito managed)

### CORS Policy
```json
{
  "allowCredentials": true,
  "allowHeaders": ["content-type", "authorization", "x-amz-date", "x-api-key"],
  "allowMethods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  "allowOrigins": [
    "http://vclipper-frontend-dev.s3-website-us-east-1.amazonaws.com",
    "https://vclipper-frontend-dev.s3.us-east-1.amazonaws.com"
  ],
  "maxAge": 86400
}
```

### Rate Limiting
- **Burst Limit**: 100 requests per client
- **Rate Limit**: 50 requests per second per client
- **Throttling**: Per-client basis with detailed metrics

## 📊 Monitoring and Logging

### CloudWatch Integration
- **Log Group**: `/aws/apigateway/vclipper` (managed by monitoring service)
- **Log Format**: JSON with request ID, IP, method, status, latency
- **Retention**: 30 days (configurable)
- **Metrics**: Request count, latency, error rates, throttling

### CloudWatch Alarms (Managed by Monitoring Service)
- **4xx Error Rate**: Client-side issues (threshold: 10)
- **5xx Error Rate**: Server-side issues (threshold: 5)
- **High Latency**: Performance monitoring (threshold: 2000ms)
- **Integration Latency**: Backend performance (threshold: 1500ms)
- **High Request Count**: Traffic monitoring (threshold: 1000)
- **WebSocket Connections**: Concurrent usage (threshold: 1000)

### Available Metrics
- API Gateway request count and latency
- HTTP status code distribution (2xx, 4xx, 5xx)
- Integration latency to backend services
- Throttling and authorization failures
- WebSocket connection and message counts

## 🔗 Integration Examples

### Frontend Integration
```javascript
// Environment configuration
const API_BASE_URL = 'https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com';
const WS_URL = 'wss://4yffht2qm0.execute-api.us-east-1.amazonaws.com/dev';

// Authenticated API call
const uploadVideo = async (file, jwtToken) => {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('userId', userId);
  
  const response = await fetch(`${API_BASE_URL}/api/videos/upload`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${jwtToken}`
    },
    body: formData,
    credentials: 'include' // Important for CORS with credentials
  });
  
  return response.json();
};

// Environment variables for React app
const envVars = {
  REACT_APP_API_BASE_URL: 'https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/',
  REACT_APP_WEBSOCKET_URL: 'wss://4yffht2qm0.execute-api.us-east-1.amazonaws.com/dev'
};
```

### Backend Integration
**Current State**: Using httpbin.org for testing
```
GET  https://httpbin.org/status/200     # Health check (placeholder)
POST https://httpbin.org/post           # Video upload (placeholder)
GET  https://httpbin.org/get            # Status/list/download (placeholder)
```

**Future State**: Backend services should implement these endpoints at the configured ALB:
```
GET  /actuator/health                    # Health check
POST /api/videos/upload                  # Video upload
GET  /api/videos/{videoId}/status        # Status check
GET  /api/videos                         # List videos
GET  /api/videos/{videoId}/download      # Download URL
```

**Migration Instructions**: When backend services are deployed:
1. Update `terraform.tfvars`: `backend_alb_dns_name = "your-alb-dns-name"`
2. Uncomment original integration URIs in `api-gateway.tf`
3. Comment out httpbin.org placeholder URIs
4. Run `terraform apply` to update integrations

## 🛠️ Troubleshooting

### Common Issues

#### JWT Authorization Failures
```bash
# Verify Cognito configuration
terraform output -state=../cognito/terraform.tfstate

# Test with current deployed API (should return 401 without token)
curl -H "Authorization: Bearer invalid_token" \
     https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/api/videos

# Test health endpoint (should work without auth)
curl https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/health
```

#### CORS Issues
- Check browser developer console for CORS errors
- Verify `cors_allow_origins` includes your frontend domain
- Ensure preflight OPTIONS requests are handled

#### Backend Integration Issues
```bash
# Test current placeholder backend
curl https://httpbin.org/status/200

# Compare with API Gateway response
curl https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/health

# When real backend is deployed, test ALB directly
# curl http://YOUR_ALB_DNS/actuator/health
```

### Useful Commands
```bash
# List API Gateways
aws apigatewayv2 get-apis

# Get current API details
aws apigatewayv2 get-api --api-id 7l5kskcnfl

# Check authorizer configuration
aws apigatewayv2 get-authorizers --api-id 7l5kskcnfl

# View recent logs
aws logs tail /aws/apigateway/vclipper --follow

# Check CloudWatch alarms
aws cloudwatch describe-alarms --alarm-name-prefix "vclipper-api-gateway"
```

## 📈 Future Enhancements

### Phase 1: WebSocket Implementation
- [ ] Lambda functions for WebSocket connection management
- [ ] DynamoDB table for connection tracking
- [ ] SNS integration for real-time status updates
- [ ] Message routing and broadcasting logic

### Phase 2: Advanced Features
- [ ] Custom domain name with SSL certificate
- [ ] API versioning strategy (v1, v2)
- [ ] Request/response transformation
- [ ] Response caching for GET endpoints

### Phase 3: Security and Monitoring
- [ ] AWS WAF integration for additional protection
- [ ] CloudWatch alarms for error rates and latency
- [ ] X-Ray tracing for request flow analysis
- [ ] API usage analytics and reporting

## 🔗 Dependencies

### Required Services
- **Global**: Project configuration and Terraform state management
- **Cognito**: User Pool and App Client for JWT authentication
- **Frontend Hosting**: S3 static website for CORS configuration

### Optional Services
- **Monitoring**: CloudWatch dashboards and metric alarms (✅ Deployed)
- **Backend Services**: Video processing application behind ALB (🔄 Future)

## 📝 Service Outputs

This service provides outputs for integration with other services:

```hcl
# Primary API endpoints
api_gateway_invoke_url = "https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/"
websocket_invoke_url   = "wss://4yffht2qm0.execute-api.us-east-1.amazonaws.com/dev"

# Frontend configuration object
frontend_api_config = {
  api_base_url   = "https://7l5kskcnfl.execute-api.us-east-1.amazonaws.com/"
  websocket_url  = "wss://4yffht2qm0.execute-api.us-east-1.amazonaws.com/dev"
  api_gateway_id = "7l5kskcnfl"
  region         = "us-east-1"
}

# Authentication details
jwt_authorizer_id = "cox1ij"
```
