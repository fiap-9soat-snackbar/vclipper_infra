provider "aws" {
  region = data.terraform_remote_state.global.outputs.aws_region
  version = "<= 5.75.0"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.vclipper.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.vclipper.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.vclipper.token
}

terraform {
#  required_version = "~> 1.10.3"

  backend "s3" {
    region = "us-east-1"
    key    = "compute/eks/vclipper/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "global/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "network/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "security_group_vclipper" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "compute/securitygroup/eks/vclipper/terraform.tfstate"
  }
}

### CLUSTER ID/AUTH ###
data "aws_eks_cluster" "vclipper" {
  name = module.eks_vclipper.cluster_id
}

data "aws_eks_cluster_auth" "vclipper" {
  name = module.eks_vclipper.cluster_id
}

### EKS NODEGROUPS ROLES ###
## GET NODE GROUPS NAMES FROM EKS CLUSTER MODULE ##
data "aws_iam_role" "role_name" {
  name = "LabRole"
}


