provider "aws" {
  region = data.terraform_remote_state.global.outputs.aws_region
}

terraform {

  backend "s3" {
    region = "us-east-1"
    key    = "network/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "global/terraform.tfstate"
  }
}
