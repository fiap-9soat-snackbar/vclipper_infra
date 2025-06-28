module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = join("-", [data.terraform_remote_state.global.outputs.project_name, "vpc"])

  cidr = data.terraform_remote_state.global.outputs.vpc_cidr

  azs             = data.terraform_remote_state.global.outputs.azs
  private_subnets = data.terraform_remote_state.global.outputs.private_subnets
  public_subnets  = data.terraform_remote_state.global.outputs.public_subnets
  database_subnets = data.terraform_remote_state.global.outputs.database_subnets
 

  enable_ipv6                                    = false
  private_subnet_assign_ipv6_address_on_creation = false
  public_subnet_ipv6_prefixes                    = [0, 1, 2]
  private_subnet_ipv6_prefixes                   = [3, 4, 5]
  database_subnet_ipv6_prefixes                  = [6, 7, 8]

  create_database_subnet_group           = false
  create_database_subnet_route_table     = false

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = true
  reuse_nat_ips          = false



  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Provisioned  = "Terraform"
    CreatedBy    = "Team-82"
    Product      = "Hackaton"
  }

  vpc_tags = {
    Name    = join("-", [data.terraform_remote_state.global.outputs.project_name, "vpc"])
    Product = data.terraform_remote_state.global.outputs.project_name
  }
}