module "sg_additional_vclipper_eks" {
  source = "terraform-aws-modules/security-group/aws"

  name        = join("-", [data.terraform_remote_state.global.outputs.project_name, "cluster-eks-prod-Additional"])
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
    Name         = join("-", [data.terraform_remote_state.global.outputs.project_name, "cluster-eks-prod-Additional"])
    Provisioned  = "Terraform"
    Product      = "Hackaton"
  }
}


module "sg_node_vclipper_eks" {
  source = "terraform-aws-modules/security-group/aws"

  name        = join("-", [data.terraform_remote_state.global.outputs.project_name, "cluster-eks-prod"])
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
    "kubernetes.io/cluster/vclipper-cluster" = "owned"
    Name                                         = join("-", [data.terraform_remote_state.global.outputs.project_name, "cluster-eks-prod"])
    Provisioned  = "Terraform"
    Product      = "Hackaton"
  }
}