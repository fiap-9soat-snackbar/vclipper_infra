provider "aws" {
  region = data.terraform_remote_state.global.outputs.aws_region


  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = local.project_name
    }
  }
}

terraform {
  backend "s3" {
    region = "us-east-1"
    key    = "global/terraform.tfstate"
  }
}
  