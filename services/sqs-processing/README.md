# VClipper SQS Processing Infrastructure

This Terraform configuration provisions AWS SQS queues for decoupled video processing with scaling and retry mechanisms for the VClipper application.

## 🚀 Features

- **Main Processing Queue**: Handles video processing jobs triggered by S3 uploads
- **Dead Letter Queue (DLQ)**: Captures failed processing jobs for analysis and retry
- **S3 Integration**: Automatically receives messages when videos are uploaded to S3
- **LabRole Access**: Backend services use existing LabRole for queue operations
- **CloudWatch Monitoring**: Alarms for queue depth and DLQ messages
- **Long Polling**: Optimized for cost and performance with 20-second polling

## 📐 Current Architecture

```
S3 Video Upload → SQS Processing Queue → Backend Processing → Success/Failure
                       ↓                        ↓
                  CloudWatch Alarms      Dead Letter Queue
                       ↓                        ↓
                  SNS Notifications      Manual Investigation
```

## 🛠️ Project Structure

```
.
├── sqs.tf                  # SQS queue configuration and policies
├── policies/               # JSON policy templates
│   ├── main_queue_policy_template.json
│   ├── dlq_policy_template.json
│   ├── redrive_policy.json
│   └── dlq_allow_policy.json
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output value definitions
├── backend.tf              # Terraform backend and provider configuration
├── terraform.tfvars        # Variable values (gitignored)
└── README.md               # This documentation
```

## 🛠️ Terraform Resources

| Resource Type | Purpose |
|---------------|---------|
| `aws_sqs_queue` | Main processing queue and dead letter queue |
| `aws_sqs_queue_policy` | Access policies for S3 and LabRole |
| `aws_sqs_queue_redrive_policy` | Failed message handling configuration |
| `aws_sqs_queue_redrive_allow_policy` | DLQ source queue permissions |
| `aws_cloudwatch_metric_alarm` | Monitoring for queue depth and DLQ messages |

## 🚀 Deployment

### Prerequisites
1. **AWS CLI Configured** with valid credentials and LabRole access
2. **Terraform v1.12+** installed
3. **Global Terraform State** deployed (for project name and region)
4. **Video Storage Service** deployed (for S3 bucket ARN)

### Configuration Variables
- `environment`: Environment name (default: "dev")
- `visibility_timeout_seconds`: Message processing timeout (default: 300)
- `message_retention_seconds`: Message retention period (default: 1209600)
- `receive_wait_time_seconds`: Long polling duration (default: 20)
- `fifo_queue`: Enable FIFO queue (default: false)

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

## 📋 Queue Configuration

After deployment, your SQS queues will be configured as:

### Main Processing Queue
- **Name**: `vclipper-video-processing-dev`
- **Type**: Standard (not FIFO)
- **Visibility Timeout**: 5 minutes
- **Message Retention**: 14 days
- **Long Polling**: 20 seconds
- **Max Receive Count**: 3 (before moving to DLQ)

### Dead Letter Queue
- **Name**: `vclipper-video-processing-dlq-dev`
- **Type**: Standard (not FIFO)
- **Message Retention**: 14 days
- **Purpose**: Failed processing jobs analysis

## 🔒 Security Configuration

### Queue Access Policies

#### Main Queue Policy
- **S3 Service**: Can send messages when videos are uploaded
- **LabRole**: Can receive, delete, and manage messages
- **Source Validation**: Only from the video storage S3 bucket

#### Dead Letter Queue Policy
- **SQS Service**: Can receive messages from main queue
- **LabRole**: Can receive, delete, and manage messages
- **Source Validation**: Only from the main processing queue

## 🔗 Integration with Other Services

### S3 Video Storage Integration
The queue receives messages automatically when videos are uploaded:

```json
{
  "Records": [
    {
      "eventVersion": "2.1",
      "eventSource": "aws:s3",
      "eventName": "ObjectCreated:Put",
      "s3": {
        "bucket": {
          "name": "vclipper-video-storage-dev"
        },
        "object": {
          "key": "videos/user123/video1.mp4"
        }
      }
    }
  ]
}
```

### Backend Processing Integration (Java/EKS)
Backend services poll the queue for processing jobs:

```java
// Example: Receive messages from SQS
@Component
public class VideoProcessingService {
    
    @Value("${sqs.video.processing.queue.url}")
    private String queueUrl;
    
    @Scheduled(fixedDelay = 5000)
    public void processVideoMessages() {
        ReceiveMessageRequest request = ReceiveMessageRequest.builder()
            .queueUrl(queueUrl)
            .maxNumberOfMessages(10)
            .waitTimeSeconds(20)  // Long polling
            .build();
            
        List<Message> messages = sqsClient.receiveMessage(request).messages();
        
        for (Message message : messages) {
            try {
                processVideo(message);
                deleteMessage(message);
            } catch (Exception e) {
                // Message will be retried up to 3 times, then moved to DLQ
                log.error("Failed to process video: {}", e.getMessage());
            }
        }
    }
}
```

### Environment Variables
Add to your backend application configuration:

```bash
# SQS Configuration
SQS_VIDEO_PROCESSING_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/668309122622/vclipper-video-processing-dev
SQS_VIDEO_PROCESSING_DLQ_URL=https://sqs.us-east-1.amazonaws.com/668309122622/vclipper-video-processing-dlq-dev
SQS_REGION=us-east-1

# Processing configuration
SQS_VISIBILITY_TIMEOUT=300
SQS_MAX_RECEIVE_COUNT=3
SQS_LONG_POLLING_SECONDS=20
```

## 🔄 Message Flow and Retry Logic

### Normal Processing Flow
```
1. Video uploaded to S3 → 2. S3 sends message to SQS → 3. Backend polls SQS
4. Backend processes video → 5. Backend deletes message → 6. Success!
```

### Failure and Retry Flow
```
1. Processing fails → 2. Message becomes visible again → 3. Retry (up to 3 times)
4. Max retries reached → 5. Message moved to DLQ → 6. CloudWatch alarm triggered
```

## 📊 CloudWatch Monitoring

### Queue Depth Alarm
- **Metric**: `ApproximateNumberOfVisibleMessages`
- **Threshold**: > 10 messages
- **Purpose**: Detect processing bottlenecks

### Dead Letter Queue Alarm
- **Metric**: `ApproximateNumberOfVisibleMessages`
- **Threshold**: > 0 messages
- **Purpose**: Detect processing failures

## 🔄 Integration with S3 Notifications (Future)

When this service is deployed, the S3 video storage service will be updated to send notifications:

```hcl
# S3 bucket notification (to be added to video-storage service)
resource "aws_s3_bucket_notification" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  queue {
    queue_arn     = data.terraform_remote_state.sqs.outputs.queue_arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "videos/"
  }
}
```

## 📊 Outputs

Key outputs for integration with other services:
- `queue_name`: SQS queue name for backend configuration
- `queue_arn`: For S3 notification configuration
- `queue_url`: For backend polling operations
- `dlq_name`: Dead letter queue name for monitoring
- `visibility_timeout_seconds`: Processing timeout configuration
- `max_receive_count`: Retry limit configuration

## 🔧 Troubleshooting

### Common Issues

#### 1. **Messages Not Being Received**
```bash
# Check queue attributes
aws sqs get-queue-attributes --queue-url <queue-url> --attribute-names All

# Check queue policy
aws sqs get-queue-attributes --queue-url <queue-url> --attribute-names Policy
```

#### 2. **Messages Going to DLQ**
```bash
# Check DLQ messages
aws sqs receive-message --queue-url <dlq-url> --max-number-of-messages 10

# Check processing logs in backend application
kubectl logs -f deployment/video-processing-service
```

#### 3. **S3 Notifications Not Working**
```bash
# Verify S3 bucket notification configuration
aws s3api get-bucket-notification-configuration --bucket vclipper-video-storage-dev

# Check SQS queue policy allows S3 to send messages
aws sqs get-queue-attributes --queue-url <queue-url> --attribute-names Policy
```

### Useful Commands
```bash
# Send test message to queue
aws sqs send-message --queue-url <queue-url> --message-body '{"test": "message"}'

# Receive messages from queue
aws sqs receive-message --queue-url <queue-url> --max-number-of-messages 10

# Check queue metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/SQS \
  --metric-name ApproximateNumberOfVisibleMessages \
  --dimensions Name=QueueName,Value=vclipper-video-processing-dev \
  --start-time 2025-06-22T00:00:00Z \
  --end-time 2025-06-22T23:59:59Z \
  --period 300 \
  --statistics Average

# Purge queue (remove all messages)
aws sqs purge-queue --queue-url <queue-url>
```
