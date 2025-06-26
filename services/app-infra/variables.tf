#--------------------------------------------------------------
# VClipper App Infrastructure Variables
#--------------------------------------------------------------

# Global Variables
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "vclipper"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
  default     = "vclipper-terraform-state-dev-rmxhnjty"
}

# Network Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

# EC2 Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "iam_instance_profile" {
  description = "IAM instance profile for EC2"
  type        = string
  default     = "LabInstanceProfile"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
}

# Application Variables
variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Health check path for ALB"
  type        = string
  default     = "/actuator/health"
}
