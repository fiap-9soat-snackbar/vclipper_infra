# VClipper App Infrastructure

This Terraform configuration provisions the application infrastructure for the VClipper video processing platform, including VPC, EC2 instance, and Application Load Balancer for running the backend services.

## 🚀 Features

- **VPC with Minimum Networking**: Public and private subnets across 2 AZs
- **EC2 Instance**: Ubuntu 24.04 with Docker Compose for running VClipper backend
- **Application Load Balancer**: HTTP load balancer for backend API access
- **Elastic IP**: Static IP address for the EC2 instance
- **Security Groups**: Minimal security configuration for ALB and EC2
- **Session Manager Access**: EC2 access via AWS Systems Manager (no SSH required)

## 📐 Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           VPC (10.0.0.0/16)                        │
├─────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                        │
│  │  Public Subnet  │    │  Public Subnet  │                        │
│  │  10.0.10.0/24   │    │  10.0.11.0/24   │                        │
│  │  (us-east-1a)   │    │  (us-east-1b)   │                        │
│  └─────────────────┘    └─────────────────┘                        │
│           │                       │                                 │
│  ┌─────────────────┐    ┌─────────────────┐                        │
│  │  Private Subnet │    │  Private Subnet │                        │
│  │  10.0.20.0/24   │    │  10.0.21.0/24   │                        │
│  │  (us-east-1a)   │    │  (us-east-1b)   │                        │
│  └─────────────────┘    └─────────────────┘                        │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Application Load Balancer                       │
│  ┌─────────────────┐    ┌─────────────────┐                        │
│  │   HTTP:80       │───▶│  Target Group   │                        │
│  │   (Public)      │    │   Port 8080     │                        │
│  └─────────────────┘    └─────────────────┘                        │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        EC2 Instance                                │
│  ┌─────────────────┐    ┌─────────────────┐                        │
│  │  VClipper App   │    │    MongoDB      │                        │
│  │  (Port 8080)    │    │  (Port 27017)   │                        │
│  │  Docker Compose │    │  Docker Compose │                        │
│  └─────────────────┘    └─────────────────┘                        │
│                                                                     │
│  • Ubuntu 24.04 LTS                                                │
│  • 30GB GP3 EBS Volume                                             │
│  • Elastic IP Address                                              │
│  • LabInstanceProfile (AWS permissions)                            │
└─────────────────────────────────────────────────────────────────────┘
```

## 🛠️ Project Structure

```
app-infra/
├── main.tf              # VPC, EC2, ALB, and security groups
├── variables.tf         # Input variable definitions
├── outputs.tf           # Output value definitions
├── backend.tf           # Terraform backend configuration
├── terraform.tfvars     # Variable values
├── user-data.sh         # EC2 initialization script
├── .env                 # Environment variables for Docker Compose
└── README.md            # This documentation
```

## 🛠️ Terraform Resources

| Resource Type | Purpose |
|---------------|---------|
| `aws_vpc` | Virtual Private Cloud with DNS support |
| `aws_subnet` | Public and private subnets across 2 AZs |
| `aws_internet_gateway` | Internet access for public subnets |
| `aws_route_table` | Routing configuration for public subnets |
| `aws_security_group` | Security groups for ALB and EC2 |
| `aws_instance` | Ubuntu 24.04 EC2 instance with user data |
| `aws_eip` | Elastic IP for static public IP address |
| `aws_lb` | Application Load Balancer |
| `aws_lb_target_group` | Target group for health checks |
| `aws_lb_listener` | HTTP listener on port 80 |

## 🚀 Deployment

### Prerequisites
1. **AWS CLI Configured** with valid credentials
2. **Terraform v1.12+** installed
3. **Global Terraform State** deployed
4. **VClipper Infrastructure Services** deployed (for AWS resource integration)

### Configuration Variables
- `project_name`: Project name (default: "vclipper")
- `environment`: Environment name (default: "dev")
- `vpc_cidr`: VPC CIDR block (default: "10.0.0.0/16")
- `instance_type`: EC2 instance type (default: "t2.micro")
- `key_name`: EC2 Key Pair name (required)
- `app_port`: Application port (default: 8080)

### Deploy App Infrastructure
```bash
cd services/app-infra/
terraform init
terraform plan
terraform apply
```

### Verify Deployment
```bash
# Check outputs
terraform output

# Test ALB health check
curl http://$(terraform output -raw alb_dns_name)/actuator/health

# Access EC2 via Session Manager
aws ssm start-session --target $(terraform output -raw ec2_instance_id)
```

## 🔧 EC2 Instance Configuration

### Automated Setup (via user-data.sh)
1. **System Updates**: Install required packages
2. **Java Installation**: Eclipse Temurin 21 JDK
3. **Maven Installation**: Maven 3.9.9 for building the application
4. **Application Build**: Clone and build VClipper processing service
5. **Docker Installation**: Docker CE and Docker Compose
6. **Environment Setup**: Configure .env with AWS production settings
7. **Application Deployment**: Start VClipper with Docker Compose

### Application Stack
- **VClipper Processing Service**: Spring Boot application (Port 8080)
- **MongoDB**: Database for video processing metadata (Port 27017)
- **Docker Compose**: Container orchestration

### AWS Integration
- **S3 Bucket**: `vclipper-video-storage-dev`
- **SQS Queue**: `vclipper-video-processing-dev`
- **SNS Topics**: Success and failure notifications
- **IAM**: Uses LabInstanceProfile for AWS permissions

## 🔐 Security Configuration

### Network Security
- **ALB Security Group**: HTTP (80) from anywhere
- **EC2 Security Group**: Application port (8080) from ALB only
- **No SSH Access**: Using AWS Systems Manager Session Manager
- **Private Subnets**: Available for future database or cache services

### Instance Security
- **Encrypted EBS**: 30GB GP3 volume with encryption
- **IAM Instance Profile**: LabInstanceProfile for AWS service access
- **Minimal Ports**: Only application port exposed to ALB

## 📊 Monitoring and Health Checks

### ALB Health Checks
- **Path**: `/actuator/health`
- **Protocol**: HTTP
- **Port**: 8080
- **Healthy Threshold**: 2 consecutive successes
- **Unhealthy Threshold**: 2 consecutive failures
- **Interval**: 30 seconds
- **Timeout**: 5 seconds

### Application Monitoring
- **Health Endpoint**: `http://ALB_DNS/actuator/health`
- **Application Logs**: Available via Docker Compose logs
- **System Access**: AWS Systems Manager Session Manager

## 🔗 Integration with API Gateway

### Backend Integration
Once deployed, update the API Gateway service to use the real backend:

1. **Get ALB DNS Name**:
   ```bash
   cd services/app-infra/
   terraform output alb_dns_name
   ```

2. **Update API Gateway Configuration**:
   ```bash
   cd services/api-gateway/
   # Update terraform.tfvars
   backend_alb_dns_name = "your-alb-dns-name"
   
   # Update api-gateway.tf (uncomment real integrations, comment httpbin.org)
   terraform apply
   ```

3. **Test Integration**:
   ```bash
   # Test via ALB directly
   curl http://your-alb-dns-name/actuator/health
   
   # Test via API Gateway
   curl https://your-api-gateway-url/health
   ```

## 🛠️ Troubleshooting

### Common Issues

#### EC2 Instance Not Starting
```bash
# Check instance status
aws ec2 describe-instances --instance-ids $(terraform output -raw ec2_instance_id)

# Check user data execution
aws ssm start-session --target $(terraform output -raw ec2_instance_id)
sudo tail -f /var/log/cloud-init-output.log
```

#### Application Not Responding
```bash
# Connect to instance
aws ssm start-session --target $(terraform output -raw ec2_instance_id)

# Check Docker containers
sudo docker ps
sudo docker logs vclipper_processing-processing-service-1

# Check application logs
cd /home/ubuntu/app/vclipper_processing
sudo docker compose logs -f
```

#### ALB Health Check Failing
```bash
# Test application directly on instance
aws ssm start-session --target $(terraform output -raw ec2_instance_id)
curl http://localhost:8080/actuator/health

# Check target group health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw alb_target_group_arn)
```

### Useful Commands
```bash
# Get all outputs
terraform output

# Connect to EC2 instance
aws ssm start-session --target $(terraform output -raw ec2_instance_id)

# Check application status
curl http://$(terraform output -raw alb_dns_name)/actuator/health

# View Docker logs
aws ssm start-session --target $(terraform output -raw ec2_instance_id)
cd /home/ubuntu/app/vclipper_processing
sudo docker compose logs -f processing-service
```

## 📈 Future Enhancements

### Phase 1: High Availability
- [ ] Multi-AZ deployment with Auto Scaling Group
- [ ] RDS database instead of containerized MongoDB
- [ ] Application Load Balancer across multiple instances

### Phase 2: Security Improvements
- [ ] HTTPS/SSL certificate for ALB
- [ ] WAF integration for additional protection
- [ ] VPC endpoints for AWS services

### Phase 3: Monitoring & Observability
- [ ] CloudWatch agent for detailed metrics
- [ ] Application Performance Monitoring (APM)
- [ ] Centralized logging with CloudWatch Logs

## 🔗 Dependencies

### Required Services
- **Global**: Project configuration and Terraform state management
- **Video Storage**: S3 bucket for video files
- **SQS Processing**: Message queue for video processing
- **SNS Notifications**: Success/failure notification topics

### Integration Services
- **API Gateway**: Will integrate with ALB for backend routing
- **Monitoring**: CloudWatch monitoring for infrastructure and application

## 📝 Service Outputs

This service provides outputs for integration with other services:

```hcl
# ALB integration
alb_dns_name = "vclipper-dev-alb-123456789.us-east-1.elb.amazonaws.com"
application_url = "http://vclipper-dev-alb-123456789.us-east-1.elb.amazonaws.com"
health_check_url = "http://vclipper-dev-alb-123456789.us-east-1.elb.amazonaws.com/actuator/health"

# Backend integration configuration
backend_integration_config = {
  alb_dns_name     = "vclipper-dev-alb-123456789.us-east-1.elb.amazonaws.com"
  health_check_url = "http://vclipper-dev-alb-123456789.us-east-1.elb.amazonaws.com/actuator/health"
  api_base_url     = "http://vclipper-dev-alb-123456789.us-east-1.elb.amazonaws.com/api"
  app_port         = 8080
}

# Infrastructure details
vpc_id = "vpc-123456789"
ec2_instance_id = "i-123456789"
ec2_public_ip = "1.2.3.4"
```
