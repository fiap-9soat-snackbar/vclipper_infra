# VClipper Monitoring Service

This Terraform configuration provisions comprehensive CloudWatch monitoring infrastructure for the VClipper video processing platform, providing centralized logging, metrics, alarms, and dashboards for all AWS services and application components.

## 🚀 Features

- **Comprehensive Log Groups**: 12 log groups covering all AWS services and application components
- **Custom Metric Filters**: Extract business metrics from application logs
- **Proactive Alarms**: Monitor infrastructure health and application performance
- **Unified Dashboard**: Single pane of glass for all monitoring data
- **Service-Agnostic Logging**: Application logs independent of compute platform
- **Security Monitoring**: Authentication failures and suspicious activity detection

## 📐 Current Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    VClipper Monitoring Service                      │
├─────────────────────────────────────────────────────────────────────┤
│  📊 CloudWatch Dashboard  │  🚨 Metric Alarms  │  📝 Log Groups     │
│  ┌─────────────────────┐  │  ┌───────────────┐  │  ┌───────────────┐ │
│  │ • SQS Metrics       │  │  │ • Queue Depth │  │  │ • AWS Services│ │
│  │ • S3 Storage        │  │  │ • Error Rates │  │  │ • Applications│ │
│  │ • SNS Delivery      │  │  │ • Auth Failures│  │  │ • Components  │ │
│  │ • Application Logs  │  │  │ • Storage Size │  │  │ • Access Logs │ │
│  └─────────────────────┘  │  └───────────────┘  │  └───────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

## 🛠️ Project Structure

```
.
├── cw-alarms.tf              # CloudWatch metric alarms
├── cw-dashboards.tf          # CloudWatch dashboards
├── cw-log-groups.tf          # Log groups and metric filters
├── data-sources.tf           # Remote state data sources
├── locals.tf                 # Local values and configurations
├── variables.tf              # Input variable definitions
├── outputs.tf                # Output value definitions
├── backend.tf                # Terraform backend configuration
├── terraform.tfvars          # Variable values
├── dashboards/               # Dashboard JSON templates
│   └── infrastructure_dashboard.json
└── README.md                 # This documentation
```

## 🛠️ Terraform Resources

### Log Groups (12 Total)

| Resource Type | Count | Purpose |
|---------------|-------|---------|
| `aws_cloudwatch_log_group` | 8 | AWS service-specific log groups |
| `aws_cloudwatch_log_group` | 4 | Application component log groups |

### Monitoring Resources

| Resource Type | Count | Purpose |
|---------------|-------|---------|
| `aws_cloudwatch_log_metric_filter` | 12 | Extract custom metrics from logs |
| `aws_cloudwatch_metric_alarm` | 15+ | Monitor infrastructure and application health |
| `aws_cloudwatch_dashboard` | 1 | Unified monitoring dashboard |

## 📊 Log Group Architecture

### AWS Service-Specific Log Groups (8)

Following AWS best practices with `/aws/{service}/` pattern:

| Log Group | Service | Purpose | Retention |
|-----------|---------|---------|-----------|
| `/aws/apigateway/vclipper` | API Gateway | Access and execution logs | 14 days |
| `/aws/eks/vclipper/cluster` | EKS | Cluster control plane logs | 14 days |
| `/aws/lambda/vclipper-authorizer` | Lambda | Authorizer function logs | 14 days |
| `/aws/s3/vclipper-frontend` | S3 | Frontend hosting access logs | 14 days |
| `/aws/s3/vclipper-video-storage` | S3 | Video storage access logs | 14 days |
| `/aws/sqs/vclipper` | SQS | Queue processing logs | 14 days |
| `/aws/sns/vclipper` | SNS | Topic delivery logs | 14 days |
| `/aws/cognito/vclipper` | Cognito | Authentication logs | 14 days |

### Application Component Log Groups (4)

Service-agnostic pattern with `/aws/application/` for compute flexibility:

| Log Group | Component | Purpose | Compute Platform |
|-----------|-----------|---------|------------------|
| `/aws/application/vclipper-frontend` | vclipper_fe | React frontend logs | Any (EC2/EKS/ECS) |
| `/aws/application/vclipper-processing` | vclipper_processing | Video processing workflow logs | Any (EC2/EKS/ECS) |
| `/aws/application/vclipper-clipping` | vclipping | Video clipping service logs | Any (EC2/EKS/ECS) |
| `/aws/application/vclipper-user` | vclipper_user | User management service logs | Any (EC2/EKS/ECS) |

## 🔍 Metric Filters & Custom Metrics

### Application Error Tracking

| Metric Filter | Log Group | Custom Metric | Namespace | Pattern |
|---------------|-----------|---------------|-----------|---------|
| `app_processing_errors` | `/aws/application/vclipper-processing` | `AppProcessingErrors` | `VClipper/Application` | `[timestamp, request_id, level="ERROR", ...]` |
| `frontend_errors` | `/aws/application/vclipper-frontend` | `FrontendErrors` | `VClipper/Frontend` | `[timestamp, request_id, level="ERROR", ...]` |
| `clipping_errors` | `/aws/application/vclipper-clipping` | `ClippingErrors` | `VClipper/Clipping` | `[timestamp, request_id, level="ERROR", ...]` |
| `user_service_errors` | `/aws/application/vclipper-user` | `UserServiceErrors` | `VClipper/UserService` | `[timestamp, request_id, level="ERROR", ...]` |

### Video Processing Metrics

| Metric Filter | Custom Metric | Pattern | Purpose |
|---------------|---------------|---------|---------|
| `video_processing_failures` | `VideoProcessingFailures` | `[timestamp, request_id, level="ERROR", message="*processing failed*", ...]` | Track processing failures |
| `video_processing_success` | `VideoProcessingSuccess` | `[timestamp, request_id, level="INFO", message="*processing completed*", ...]` | Track successful processing |

### S3 Access Log Metrics

| Metric Filter | Custom Metric | Pattern | Purpose |
|---------------|---------------|---------|---------|
| `s3_frontend_4xx_errors` | `S3Frontend4xxErrors` | `[timestamp, bucket_owner, bucket, time, remote_ip, requester, request_id, operation, key, request_uri, http_status_code=4*, ...]` | Client-side errors |
| `s3_frontend_5xx_errors` | `S3Frontend5xxErrors` | `[timestamp, bucket_owner, bucket, time, remote_ip, requester, request_id, operation, key, request_uri, http_status_code=5*, ...]` | Server-side errors |
| `s3_video_storage_errors` | `S3VideoStorageErrors` | `[timestamp, bucket_owner, bucket, time, remote_ip, requester, request_id, operation, key, request_uri, http_status_code=4*\|\|http_status_code=5*, ...]` | Video storage access errors |

### Cognito Security Metrics

| Metric Filter | Custom Metric | Pattern | Purpose |
|---------------|---------------|---------|---------|
| `cognito_auth_failures` | `CognitoAuthFailures` | `[timestamp, request_id, level="ERROR", message="*authentication failed*" \|\| message="*login failed*" \|\| message="*invalid credentials*", ...]` | Authentication failures |
| `cognito_suspicious_activity` | `CognitoSuspiciousActivity` | `[timestamp, request_id, level, message="*brute force*" \|\| message="*multiple failed attempts*" \|\| message="*suspicious*", ...]` | Security threat detection |

## 🚨 CloudWatch Alarms

### Infrastructure Alarms

| Alarm | Metric | Threshold | Evaluation Periods | Purpose |
|-------|--------|-----------|-------------------|---------|
| `sqs_queue_depth` | SQS ApproximateNumberOfVisibleMessages | 100 messages | 2 | Queue backlog detection |
| `sqs_message_age` | SQS ApproximateAgeOfOldestMessage | 300 seconds | 2 | Message processing delays |
| `sqs_dlq_messages` | SQS DLQ Messages | 1 message | 1 | Dead letter queue monitoring |
| `s3_video_bucket_size` | S3 BucketSizeBytes | 50GB | 2 | Storage capacity monitoring |
| `s3_frontend_bucket_size` | S3 BucketSizeBytes | 10GB | 2 | Frontend storage monitoring |
| `s3_video_request_rate` | S3 AllRequests | 1000 requests | 2 | Video storage request monitoring |
| `s3_frontend_request_rate` | S3 AllRequests | 500 requests | 2 | Frontend request monitoring |

### Application Alarms

| Alarm | Metric | Threshold | Evaluation Periods | Severity |
|-------|--------|-----------|-------------------|----------|
| `application_error_rate` | AppProcessingErrors | 10 errors | 2 | High |
| `video_processing_failure_rate` | VideoProcessingFailures | 5 failures | 1 | Critical |
| `cognito_auth_failure_rate` | CognitoAuthFailures | 15 failures | 2 | High |
| `cognito_suspicious_activity_rate` | CognitoSuspiciousActivity | 3 events | 1 | Critical |

### S3 Access Alarms

| Alarm | Metric | Threshold | Evaluation Periods | Severity |
|-------|--------|-----------|-------------------|----------|
| `s3_frontend_4xx_error_rate` | S3Frontend4xxErrors | 10 errors | 2 | Medium |
| `s3_frontend_5xx_error_rate` | S3Frontend5xxErrors | 5 errors | 1 | High |

### SNS Delivery Alarms

| Alarm | Metric | Threshold | Purpose |
|-------|--------|-----------|---------|
| `sns_success_delivery_failures` | SNS NumberOfNotificationsFailed | 5 failures | Success topic delivery monitoring |
| `sns_failure_delivery_failures` | SNS NumberOfNotificationsFailed | 5 failures | Failure topic delivery monitoring |
| `sns_failure_high_volume` | SNS NumberOfNotificationsDelivered | 50 notifications | High failure notification volume |

## 📈 CloudWatch Dashboard

### VClipper Infrastructure Dashboard

**Dashboard Name**: `VClipper-Infrastructure-dev`

**Layout**: 7 panels in optimized grid layout

#### Panel Configuration

| Panel | Position | Metrics | Purpose |
|-------|----------|---------|---------|
| **SQS Queue Metrics** | Top-left (12x6) | Queue depth, DLQ messages, message age | Queue health monitoring |
| **S3 Video Storage Metrics** | Top-right (12x6) | Storage size, request rates | Video storage monitoring |
| **S3 Frontend Hosting Metrics** | Middle-left (12x6) | Storage size, requests, 4xx errors | Frontend hosting monitoring |
| **Cognito Authentication Metrics** | Middle-right (12x6) | Sign-in failures, token refresh failures | Authentication monitoring |
| **SNS Notification Metrics** | Bottom-left (12x6) | Delivery success/failure rates | Notification monitoring |
| **Application Metrics** | Bottom-right (12x6) | Error rates, processing success/failure | Application health monitoring |
| **Recent Application Errors** | Bottom-full (24x6) | Live error log query | Real-time error analysis |

#### Dashboard Features

- **Time Range**: Last 3 hours with auto-refresh
- **Period**: 5-minute intervals for detailed monitoring
- **Log Insights**: Real-time error log queries
- **Metric Math**: Calculated success rates and error percentages

## 🚀 Deployment

### Prerequisites
1. **AWS CLI Configured** with valid credentials
2. **Terraform v1.12+** installed
3. **Dependent Services** deployed:
   - Global configuration
   - SQS Processing
   - SNS Notifications
   - Video Storage
   - Frontend Hosting
   - Cognito

### Configuration Variables
- `log_retention_days`: Log retention period (default: 14 days)
- `alarm_period_seconds`: Alarm evaluation period (default: 300 seconds)
- `cognito_auth_failure_threshold`: Cognito auth failure threshold (default: 15)

### Deploy Steps
```bash
cd services/monitoring/
terraform init
terraform plan
terraform apply
```

### Verify Deployment
```bash
# Check outputs
terraform output

# Verify log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/" --region us-east-1

# Access dashboard
terraform output infrastructure_dashboard_url
```

## 📊 Key Outputs

| Output | Description | Example Value |
|--------|-------------|---------------|
| `infrastructure_dashboard_name` | CloudWatch dashboard name | `VClipper-Infrastructure-dev` |
| `infrastructure_dashboard_url` | Direct link to dashboard | `https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=VClipper-Infrastructure-dev` |
| `monitoring_config` | Complete monitoring configuration | Complex object with all log groups, alarms, and dashboards |
| `app_*_log_group_name` | Application log group names | `/aws/application/vclipper-processing` |
| `*_alarm_name` | CloudWatch alarm names | `vclipper-application-error-rate` |

## 📊 Monitoring Best Practices

### Log Patterns

**Application Logs**:
```
[timestamp, request_id, level="ERROR", ...]
[timestamp, request_id, level="INFO", message="*processing completed*", ...]
```

**S3 Access Logs**:
```
[timestamp, bucket_owner, bucket, time, remote_ip, requester, request_id, operation, key, request_uri, http_status_code, ...]
```

### Metric Namespaces

- `VClipper/Application` - Application-level metrics
- `VClipper/Frontend` - Frontend-specific metrics
- `VClipper/Clipping` - Video clipping metrics
- `VClipper/UserService` - User management metrics
- `VClipper/VideoProcessing` - Video processing metrics
- `VClipper/Cognito` - Authentication metrics
- `VClipper/S3Frontend` - Frontend S3 metrics
- `VClipper/S3VideoStorage` - Video storage metrics

### Log Analysis Queries

**Recent Errors**:
```
SOURCE '/aws/application/vclipper-processing' 
| fields @timestamp, @message 
| filter @message like /ERROR/ 
| sort @timestamp desc 
| limit 20
```

**Processing Success Rate**:
```
SOURCE '/aws/application/vclipper-processing' 
| filter @message like /processing completed/ or @message like /processing failed/
| stats count() by bin(5m)
```

**Authentication Failure Analysis**:
```
SOURCE '/aws/cognito/vclipper' 
| fields @timestamp, @message 
| filter @message like /authentication failed/ 
| stats count() by bin(1h)
```

## 🔧 Configuration

### Alarm Thresholds

| Alarm Type | Default Threshold | Customizable | Purpose |
|------------|-------------------|--------------|---------|
| SQS Queue Depth | 100 messages | ✅ | Queue backlog detection |
| Application Errors | 10 errors | ✅ | Application health monitoring |
| Cognito Auth Failures | 15 failures | ✅ | Authentication security |
| S3 Storage Size | 50GB (video), 10GB (frontend) | ✅ | Storage capacity monitoring |

### Custom Configuration

```hcl
# terraform.tfvars
log_retention_days = 30
alarm_period_seconds = 600
cognito_auth_failure_threshold = 20

# Additional alarm thresholds
sqs_queue_depth_threshold = 150
application_error_threshold = 15
```

### Custom Metrics

| Metric | Namespace | Source | Unit |
|--------|-----------|--------|------|
| `AppProcessingErrors` | VClipper/Application | Application error logs | Count |
| `VideoProcessingFailures` | VClipper/VideoProcessing | Processing failure logs | Count |
| `CognitoAuthFailures` | VClipper/Cognito | Authentication failure logs | Count |
| `S3Frontend4xxErrors` | VClipper/S3Frontend | S3 access logs | Count |

## 🔗 Integration

### With Other Services
```hcl
# Reference monitoring outputs
data "terraform_remote_state" "monitoring" {
  backend = "s3"
  config = {
    bucket = "vclipper-terraform-state-dev-rmxhnjty"
    key    = "services/monitoring/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use log group in application
resource "aws_lambda_function" "example" {
  # ... other configuration
  
  environment {
    variables = {
      LOG_GROUP = data.terraform_remote_state.monitoring.outputs.app_processing_log_group_name
    }
  }
}
```

### Dashboard Access
- **URL**: Available in `infrastructure_dashboard_url` output
- **Name**: `VClipper-Infrastructure-dev`
- **Panels**: SQS, S3, SNS, Cognito, Application metrics
- **Refresh**: Auto-refresh every 5 minutes

## 🔍 Troubleshooting

### Common Issues

#### 1. Missing Log Data
```bash
# Check if log groups exist
aws logs describe-log-groups --region us-east-1

# Verify log group permissions
aws logs describe-resource-policies --region us-east-1
```

#### 2. Alarm Not Triggering
```bash
# Check alarm state
aws cloudwatch describe-alarms --alarm-names "vclipper-application-error-rate" --region us-east-1

# View alarm history
aws cloudwatch describe-alarm-history --alarm-name "vclipper-application-error-rate" --region us-east-1
```

#### 3. Dashboard Not Loading
```bash
# Verify dashboard exists
aws cloudwatch list-dashboards --region us-east-1

# Check dashboard body
aws cloudwatch get-dashboard --dashboard-name "VClipper-Infrastructure-dev" --region us-east-1
```

### Useful Commands
```bash
# Check alarm states
aws cloudwatch describe-alarms --region us-east-1

# View recent logs
aws logs tail /aws/application/vclipper-processing --follow --region us-east-1

# Test metric filters
aws logs filter-log-events --log-group-name "/aws/application/vclipper-processing" --filter-pattern "[timestamp, request_id, level=\"ERROR\", ...]" --region us-east-1

# Get metric statistics
aws cloudwatch get-metric-statistics --namespace "VClipper/Application" --metric-name "AppProcessingErrors" --start-time 2024-01-01T00:00:00Z --end-time 2024-01-01T23:59:59Z --period 3600 --statistics Sum --region us-east-1
```

## 📋 Dependencies

### Required Services
- **Global**: Project configuration and shared resources
- **SQS Processing**: Queue metrics and alarms
- **SNS Notifications**: Notification delivery monitoring
- **Video Storage**: S3 storage metrics
- **Frontend Hosting**: Frontend S3 metrics
- **Cognito**: Authentication monitoring

### Service Dependencies
```
Global (Required First)
├── SQS Processing
├── SNS Notifications  
├── Video Storage
├── Frontend Hosting
├── Cognito
└── Monitoring (This Service) ← Depends on all above
```

---

**Status**: ✅ **Deployed and Active**  
**Environment**: Development  
**Region**: us-east-1
