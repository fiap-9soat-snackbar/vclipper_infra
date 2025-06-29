module "sg_additional_vclipper_eks" {
  source = "terraform-aws-modules/security-group/aws"

  name        = join("-", [data.terraform_remote_state.global.outputs.project_name, "Additional-vclipper-EKS"])
  description = join(":", [data.terraform_remote_state.global.outputs.project_name, "default additional vclipper security group"])
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id


  ingress_cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block, "10.30.0.0/16"]
  #ingress_rules       = ["all-all"]

  ingress_with_self = [{
    rule        = "all-all"
    description = "Allow additional to communicate with self."
  }]


  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "10.30.0.0/16"
      description = "Allow all traffic from 10.30.0.0/16"
    },
    {
      rule        = "all-all"
      cidr_blocks = "10.40.0.0/16"
      description = "Allow all traffic from 10.40.0.0/16"
    }
  ]


  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name         = join("-", [data.terraform_remote_state.global.outputs.project_name, "Additional-vclipper-EKS"])
    Provisioned  = "Terraform"
    CreatedBy    = "Team-82"
    Product      = "Hackaton"
  }
}


module "sg_node_vclipper_eks" {
  source = "terraform-aws-modules/security-group/aws"

  name        = join("-", [data.terraform_remote_state.global.outputs.project_name, "Node-vclipper-EKS"])
  description = join(":", [data.terraform_remote_state.global.outputs.project_name, "default Node vclipper security group"])
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block, "10.30.0.0/16"]
  #ingress_rules       = ["all-all"]

  ingress_with_self = [{
    rule        = "all-all"
    description = "Allow node to communicate with each other."
  }]


  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "10.30.0.0/16"
      description = "Allow all traffic from 10.30.0.0/16"
    },
    {
      rule        = "all-all"
      cidr_blocks = "10.40.0.0/16"
      description = "Allow all traffic from 10.40.0.0/16"
    }
  ]
  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    "kubernetes.io/cluster/snackbar-vclipper" = "owned"
    Name                                         = join("-", [data.terraform_remote_state.global.outputs.project_name, "Node-Cluster-1-prod-EKS"])
    Provisioned  = "Terraform"
    CreatedBy    = "Team-82"
    Product      = "Hackaton"
  }
}