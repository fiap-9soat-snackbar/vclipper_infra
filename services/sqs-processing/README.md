# VClipper SQS Processing Infrastructure

This Terraform configuration provisions AWS SQS queues for decoupled video processing with scaling and retry mechanisms for the VClipper application.

## 🚀 Features

- **Main Processing Queue**: Handles video processing jobs triggered by S3 uploads
- **VClipping Results Queue**: Handles processing results from vclipping microservice
- **Dead Letter Queues (DLQ)**: Captures failed processing jobs for analysis and retry
- **S3 Integration**: Automatically receives messages when videos are uploaded to S3
- **LabRole Access**: Backend services use existing LabRole for queue operations
- **CloudWatch Monitoring**: Alarms for queue depth and DLQ messages
- **Long Polling**: Optimized for cost and performance with 20-second polling

## 📐 Current Architecture

```
vclipper_processing → [video-processing-dev] → vclipping → [vclipping-results-dev] → vclipper_processing
                           ↓                                      ↓
                    CloudWatch Alarms                    CloudWatch Alarms
                           ↓                                      ↓
                    SNS Notifications                   SNS Notifications
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
| `aws_sqs_queue` | Main processing queues and dead letter queues |
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

### Main Processing Queue (vclipper_processing → vclipping)
- **Name**: `vclipper-video-processing-dev`
- **Type**: Standard (not FIFO)
- **Visibility Timeout**: 5 minutes
- **Message Retention**: 14 days
- **Long Polling**: 20 seconds
- **Max Receive Count**: 3 (before moving to DLQ)

### VClipping Results Queue (vclipping → vclipper_processing)
- **Name**: `vclipper-vclipping-results-dev`
- **Type**: Standard (not FIFO)
- **Visibility Timeout**: 5 minutes
- **Message Retention**: 14 days
- **Long Polling**: 20 seconds
- **Max Receive Count**: 3 (before moving to DLQ)

### Dead Letter Queues
- **Processing DLQ**: `vclipper-video-processing-dlq-dev`
- **Results DLQ**: `vclipper-vclipping-results-dlq-dev`
- **Message Retention**: 14 days
- **Purpose**: Failed processing jobs analysis

## 🔒 Security Configuration

### Queue Access Policies

#### Main Queue Policy
- **S3 Service**: Can send messages when videos are uploaded
- **LabRole**: Can receive, delete, and manage messages
- **Source Validation**: Only from the video storage S3 bucket

#### Results Queue Policy
- **VClipping Service**: Can send processing results
- **VClipper Processing**: Can receive processing results
- **LabRole**: Can receive, delete, and manage messages

#### Dead Letter Queue Policy
- **SQS Service**: Can receive messages from main queues
- **LabRole**: Can receive, delete, and manage messages
- **Source Validation**: Only from the respective main queues

## 🔗 Integration with Other Services

### S3 Video Storage Integration
The main processing queue receives messages automatically when videos are uploaded:

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

### VClipping Microservice Integration
The vclipping service sends processing results:

```json
{
  "taskId": "task-123",
  "status": "COMPLETED",
  "result": {
    "framesExtracted": 120,
    "outputLocation": "s3://bucket/vclipping-frames/task-123-frames.zip",
    "processingTime": 45.2,
    "metadata": {
      "videoDuration": 120.0,
      "frameCount": 120,
      "resolution": "1920x1080"
    }
  }
}
```

### Backend Processing Integration (Java/EKS)
Backend services poll the queues for processing jobs:

```java
// Example: Receive messages from SQS
@Component
public class VideoProcessingService {
    
    @Value("${sqs.video.processing.queue.url}")
    private String processingQueueUrl;
    
    @Value("${sqs.vclipping.results.queue.url}")
    private String resultsQueueUrl;
    
    @Scheduled(fixedDelay = 5000)
    public void processVideoMessages() {
        ReceiveMessageRequest request = ReceiveMessageRequest.builder()
            .queueUrl(processingQueueUrl)
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
    
    @Scheduled(fixedDelay = 5000)
    public void processResultMessages() {
        ReceiveMessageRequest request = ReceiveMessageRequest.builder()
            .queueUrl(resultsQueueUrl)
            .maxNumberOfMessages(10)
            .waitTimeSeconds(20)  // Long polling
            .build();
            
        List<Message> messages = sqsClient.receiveMessage(request).messages();
        
        for (Message message : messages) {
            try {
                processResult(message);
                deleteMessage(message);
            } catch (Exception e) {
                log.error("Failed to process result: {}", e.getMessage());
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
SQS_VCLIPPING_RESULTS_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/668309122622/vclipper-vclipping-results-dev
SQS_VCLIPPING_RESULTS_DLQ_URL=https://sqs.us-east-1.amazonaws.com/668309122622/vclipper-vclipping-results-dlq-dev
SQS_REGION=us-east-1

# Processing configuration
SQS_VISIBILITY_TIMEOUT=300
SQS_MAX_RECEIVE_COUNT=3
SQS_LONG_POLLING_SECONDS=20
```

## 🔄 Message Flow and Retry Logic

### Normal Processing Flow
```
1. Video uploaded to S3 → 2. S3 sends message to processing queue → 3. VClipping polls queue
4. VClipping processes video → 5. VClipping sends result to results queue → 6. VClipper Processing receives result
```

### Failure and Retry Flow
```
1. Processing fails → 2. Message becomes visible again → 3. Retry (up to 3 times)
4. Max retries reached → 5. Message moved to DLQ → 6. CloudWatch alarm triggered
```

## 📊 CloudWatch Monitoring

### Queue Depth Alarms
- **Metric**: `ApproximateNumberOfVisibleMessages`
- **Threshold**: > 10 messages
- **Purpose**: Detect processing bottlenecks

### Dead Letter Queue Alarms
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

### Main Processing Queue
- `queue_name`: SQS queue name for backend configuration
- `queue_arn`: For S3 notification configuration
- `queue_url`: For backend polling operations
- `dlq_name`: Dead letter queue name for monitoring

### VClipping Results Queue
- `vclipping_results_queue_name`: Results queue name
- `vclipping_results_queue_arn`: Results queue ARN
- `vclipping_results_queue_url`: Results queue URL for polling
- `vclipping_results_dlq_name`: Results DLQ name for monitoring

### Configuration
- `visibility_timeout_seconds`: Processing timeout configuration
- `max_receive_count`: Retry limit configuration
- `message_retention_seconds`: Message retention period

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
# List all VClipper queues
aws sqs list-queues --queue-name-prefix vclipper

# Send test message to processing queue
aws sqs send-message --queue-url <processing-queue-url> --message-body '{"test": "message"}'

# Send test message to results queue
aws sqs send-message --queue-url <results-queue-url> --message-body '{"test": "result"}'

# Receive messages from queue
aws sqs receive-message --queue-url <queue-url> --max-number-of-messages 10

# Check queue metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/SQS \
  --metric-name ApproximateNumberOfVisibleMessages \
  --dimensions Name=QueueName,Value=vclipper-video-processing-dev \
  --start-time 2025-07-05T00:00:00Z \
  --end-time 2025-07-05T23:59:59Z \
  --period 300 \
  --statistics Average

# Purge queue (remove all messages)
aws sqs purge-queue --queue-url <queue-url>
```

## 🎯 Queue Summary

After deployment, you will have **4 queues total**:

1. **`vclipper-video-processing-dev`** - Main processing requests
2. **`vclipper-video-processing-dlq-dev`** - Failed processing requests
3. **`vclipper-vclipping-results-dev`** - Processing results
4. **`vclipper-vclipping-results-dlq-dev`** - Failed result messages

This architecture supports the complete bidirectional communication between `vclipper_processing` and `vclipping` microservices.
