# VClipper App Infrastructure Configuration
project_name = "vclipper"
environment  = "dev"
aws_region   = "us-east-1"

# Terraform State
terraform_state_bucket = "vclipper-terraform-state-dev-rmxhnjty"

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnets     = ["10.0.10.0/24", "10.0.11.0/24"]
private_subnets    = ["10.0.20.0/24", "10.0.21.0/24"]

# EC2 Configuration
instance_type        = "t2.micro"
iam_instance_profile = "LabInstanceProfile"
key_name            = "vockey"  # Update with your key pair name
my_ip               = "0.0.0.0/0"  # Not used since we're using Session Manager

# Application Configuration
app_port           = 8080
health_check_path  = "/actuator/health"
