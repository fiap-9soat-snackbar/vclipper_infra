# VClipper SNS Notifications Infrastructure

This Terraform configuration provisions AWS SNS topics for video processing notifications, integrating with CloudWatch alarms and providing flexible notification delivery for the VClipper application.

## 🚀 Features

- **Success Notifications**: SNS topic for successful video processing events
- **Failure Notifications**: SNS topic for failed processing and system alerts
- **CloudWatch Integration**: Automatic alarm notifications via SNS
- **Email Subscriptions**: Optional admin email notifications
- **SMS Subscriptions**: Optional SMS alerts for critical failures
- **LabRole Access**: Backend services can publish notifications using existing LabRole
- **Retry Logic**: Configurable delivery retry policies

## 📐 Current Architecture

```
Backend Processing → SNS Topics → Multiple Delivery Channels
       ↓                ↓              ↓
CloudWatch Alarms → Success/Failure → Email/SMS/HTTP
       ↓                ↓              ↓
SQS Queue Depth → Topic Policies → Admin Notifications
```

## 🛠️ Project Structure

```
.
├── sns.tf                  # SNS topics and subscriptions configuration
├── policies/               # JSON policy templates
│   ├── topic_policy_template.json
│   └── delivery_policy.json
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output value definitions
├── backend.tf              # Terraform backend and provider configuration
├── terraform.tfvars        # Variable values (gitignored)
└── README.md               # This documentation
```

## 🛠️ Terraform Resources

| Resource Type | Purpose |
|---------------|---------|
| `aws_sns_topic` | Success and failure notification topics |
| `aws_sns_topic_policy` | Access policies for LabRole and CloudWatch |
| `aws_sns_topic_subscription` | Email and SMS subscriptions (optional) |
| `aws_cloudwatch_metric_alarm` | Updated alarms with SNS integration |

## 🚀 Deployment

### Prerequisites
1. **AWS CLI Configured** with valid credentials and LabRole access
2. **Terraform v1.12+** installed
3. **Global Terraform State** deployed (for project name and region)
4. **SQS Processing Service** deployed (for CloudWatch alarm integration)

### Configuration Variables
- `environment`: Environment name (default: "dev")
- `enable_email_notifications`: Enable admin email alerts (default: false)
- `admin_email`: Admin email address for notifications
- `enable_sms_notifications`: Enable SMS alerts (default: false)
- `admin_phone_number`: Phone number for SMS alerts (+1234567890 format)
- `delivery_retry_policy`: Number of delivery retry attempts (default: 3)

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

## 📋 SNS Topics Configuration

After deployment, your SNS topics will be configured as:

### Success Notifications Topic
- **Name**: `vclipper-video-processing-success-dev`
- **Purpose**: Successful video processing events
- **Subscribers**: Optional admin email
- **Delivery Policy**: 3 retry attempts with linear backoff

### Failure Notifications Topic
- **Name**: `vclipper-video-processing-failure-dev`
- **Purpose**: Failed processing and system alerts
- **Subscribers**: Admin email and SMS (if enabled)
- **Delivery Policy**: 3 retry attempts with linear backoff

## 🔒 Security Configuration

### Topic Access Policies

#### Backend Publishing Access
- **LabRole**: Can publish messages and get topic attributes
- **CloudWatch**: Can publish alarm notifications
- **Source Validation**: Account-level restrictions

#### Subscription Security
- **Email**: Requires manual confirmation via email
- **SMS**: Requires phone number verification
- **HTTP/HTTPS**: Can be added for webhook integrations

## 🔗 Integration with Other Services

### CloudWatch Alarms Integration
SNS automatically receives notifications from:

```bash
# Queue depth alarm (when > 10 messages)
Queue Depth High → Failure Topic → Admin Notifications

# Dead letter queue messages (when > 0 messages)
DLQ Messages → Failure Topic → Critical Alerts

# Alarm recovery
Alarm OK → Success Topic → Recovery Notifications
```

### Backend Services Integration (Java/EKS)
Backend services can publish custom notifications:

```java
// Example: Publish success notification
@Service
public class NotificationService {
    
    @Value("${sns.success.topic.arn}")
    private String successTopicArn;
    
    @Value("${sns.failure.topic.arn}")
    private String failureTopicArn;
    
    public void notifyVideoProcessingSuccess(String userId, String videoId) {
        PublishRequest request = PublishRequest.builder()
            .topicArn(successTopicArn)
            .subject("Video Processing Complete")
            .message(buildSuccessMessage(userId, videoId))
            .messageAttributes(Map.of(
                "userId", MessageAttributeValue.builder()
                    .dataType("String")
                    .stringValue(userId)
                    .build(),
                "videoId", MessageAttributeValue.builder()
                    .dataType("String")
                    .stringValue(videoId)
                    .build()
            ))
            .build();
            
        snsClient.publish(request);
    }
    
    public void notifyVideoProcessingFailure(String userId, String videoId, String error) {
        PublishRequest request = PublishRequest.builder()
            .topicArn(failureTopicArn)
            .subject("Video Processing Failed")
            .message(buildFailureMessage(userId, videoId, error))
            .build();
            
        snsClient.publish(request);
    }
}
```

### Environment Variables
Add to your backend application configuration:

```bash
# SNS Configuration
SNS_SUCCESS_TOPIC_ARN=arn:aws:sns:us-east-1:668309122622:vclipper-video-processing-success-dev
SNS_FAILURE_TOPIC_ARN=arn:aws:sns:us-east-1:668309122622:vclipper-video-processing-failure-dev
SNS_REGION=us-east-1

# Notification settings
SNS_DELIVERY_RETRY_POLICY=3
SNS_MESSAGE_RETENTION_SECONDS=1209600
```

## 📧 Email and SMS Setup

### Enable Email Notifications
1. Update `terraform.tfvars`:
```bash
enable_email_notifications = true
admin_email = "admin@yourcompany.com"
```

2. Apply Terraform changes:
```bash
terraform apply
```

3. **Important**: Check your email for AWS SNS confirmation and click the confirmation link.

### Enable SMS Notifications
1. Update `terraform.tfvars`:
```bash
enable_sms_notifications = true
admin_phone_number = "+1234567890"  # Include country code
```

2. Apply Terraform changes and confirm SMS subscription via text message.

## 🔄 Message Formats

### Success Notification Format
```json
{
  "userId": "user123",
  "videoId": "video456",
  "status": "success",
  "message": "Video processing completed successfully",
  "timestamp": "2025-06-22T16:00:00Z",
  "processingTime": "45 seconds",
  "outputLocation": "s3://vclipper-video-storage-dev/clips/user123/video456_clips.zip"
}
```

### Failure Notification Format
```json
{
  "userId": "user123",
  "videoId": "video456",
  "status": "failure",
  "error": "Video format not supported",
  "message": "Failed to process video after 3 attempts",
  "timestamp": "2025-06-22T16:00:00Z",
  "retryCount": 3,
  "lastError": "Unsupported codec: xyz"
}
```

## 📊 Monitoring and Alerting

### CloudWatch Integration
- **Queue Depth Alarm**: Triggers failure notifications when queue has >10 messages
- **DLQ Messages Alarm**: Triggers critical alerts when messages appear in DLQ
- **Alarm Recovery**: Sends success notifications when alarms return to OK state

### Custom Metrics (Future Enhancement)
```bash
# Custom CloudWatch metrics for notification delivery
aws cloudwatch put-metric-data \
  --namespace "VClipper/Notifications" \
  --metric-data MetricName=NotificationsSent,Value=1,Unit=Count
```

## 📊 Outputs

Key outputs for integration with other services:
- `success_topic_arn`: For backend success notifications
- `failure_topic_arn`: For backend failure notifications
- `notification_endpoints`: Complete configuration object
- `admin_email_subscriptions`: Email subscription ARNs
- `admin_sms_subscriptions`: SMS subscription ARNs

## 🔧 Troubleshooting

### Common Issues

#### 1. **Email Notifications Not Working**
```bash
# Check subscription status
aws sns list-subscriptions-by-topic --topic-arn <success-topic-arn>

# Verify email confirmation
# Check spam folder for AWS SNS confirmation email
```

#### 2. **SMS Notifications Not Working**
```bash
# Check SMS subscription
aws sns list-subscriptions-by-topic --topic-arn <failure-topic-arn>

# Verify phone number format (+1234567890)
# Check for SMS confirmation message
```

#### 3. **Backend Publishing Failures**
```bash
# Check topic policy
aws sns get-topic-attributes --topic-arn <topic-arn>

# Verify LabRole permissions
aws sts get-caller-identity

# Test publishing
aws sns publish --topic-arn <topic-arn> --message "Test message"
```

### Useful Commands
```bash
# List all SNS topics
aws sns list-topics | grep vclipper

# Check topic subscriptions
aws sns list-subscriptions-by-topic --topic-arn <topic-arn>

# Send test notification
aws sns publish \
  --topic-arn <topic-arn> \
  --subject "Test Notification" \
  --message "This is a test message from VClipper"

# Check delivery status
aws sns get-subscription-attributes --subscription-arn <subscription-arn>

# Monitor CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/SNS \
  --metric-name NumberOfNotificationsFailed \
  --dimensions Name=TopicName,Value=vclipper-video-processing-failure-dev \
  --start-time 2025-06-22T00:00:00Z \
  --end-time 2025-06-22T23:59:59Z \
  --period 3600 \
  --statistics Sum
```

## 🔄 Future Enhancements

### Planned Features
- **Lambda Function**: Custom notification processing and routing
- **Webhook Support**: HTTP/HTTPS endpoint subscriptions
- **User-Specific Notifications**: Personalized messages based on user preferences
- **Notification Templates**: Customizable message formats
- **Delivery Analytics**: Detailed metrics and reporting
