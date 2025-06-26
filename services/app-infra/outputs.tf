#--------------------------------------------------------------
# VClipper App Infrastructure Outputs
#--------------------------------------------------------------

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# EC2 Outputs
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance (Elastic IP)"
  value       = aws_eip.app_server.public_ip
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "elastic_ip_id" {
  description = "Allocation ID of the Elastic IP"
  value       = aws_eip.app_server.id
}

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

# Application URLs
output "application_url" {
  description = "URL to access the application via ALB"
  value       = "http://${aws_lb.main.dns_name}"
}

output "health_check_url" {
  description = "Health check URL"
  value       = "http://${aws_lb.main.dns_name}${var.health_check_path}"
}

# Integration Configuration
output "backend_integration_config" {
  description = "Configuration for API Gateway backend integration"
  value = {
    alb_dns_name      = aws_lb.main.dns_name
    health_check_url  = "http://${aws_lb.main.dns_name}${var.health_check_path}"
    api_base_url      = "http://${aws_lb.main.dns_name}/api"
    app_port          = var.app_port
  }
}

# Security Group IDs
output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}
