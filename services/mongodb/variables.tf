# MongoDB Atlas variables

variable "org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
  sensitive   = true
}

variable "mongodb_cluster_name" {
  description = "Mongo Endpoint"
  type        = string

}

variable "mongodbatlas_org_public_key" {
  description = "MongoDB Atlas Organization public key"
  type        = string
  sensitive   = true
}

variable "mongodbatlas_org_private_key" {
  description = "MongoDB Atlas Organization private key"
  type        = string
  sensitive   = true
}

variable "mongodbatlas_username" {
  description = "MongoDB Atlas username"
  type        = string
}

variable "mongodbatlas_password" {
  description = "MongoDB Atlas password"
  type        = string
  sensitive   = true
}

variable "MONGODB_USER" {
  description = "MongoDB username"
  type        = string
}

variable "MONGODB_PASSWORD" {
  description = "MongoDB password"
  type        = string
  sensitive   = true
}

variable "aws_nat_gateway" {
  description = "AWS NAT gateway public IP" 
  type        = string

}

variable "bucket" {
  description = "bucket tf state"
  type        = string

}