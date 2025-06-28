# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# CIDR blocks
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Private Subnets
output "database_subnets" {
  description = "List of IDs of Database subnets"
  value       = module.vpc.database_subnets
}

# Private Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

# Private Subnets A
output "private_subnet_a" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets[0]
}

# Private Subnets B
output "private_subnet_b" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets[2]
}

# Private Subnets C
output "private_subnet_c" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets[1]
}

# Public Subnet All
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# Public Subnet A
output "public_subnet_a" {
  description = "Public Subnet from AZ A"
  value       = module.vpc.public_subnets[0]
}

# Public Subnet C
output "public_subnet_c" {
  description = "Public Subnet from AZ C"
  value       = module.vpc.public_subnets[1]
}

# Public Subnet B
output "public_subnet_b" {
  description = "Public Subnet from AZ B"
  value       = module.vpc.public_subnets[2]
}


# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# AZs
output "azs" {
  description = "A list of availability zones spefified as argument to this module"
  value       = module.vpc.azs
}

output "security_group_id" {
  description = "A default SG of VPC"
  value       = module.vpc.default_security_group_id
}


output "public_route_table" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}


output "private_route_table" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}
