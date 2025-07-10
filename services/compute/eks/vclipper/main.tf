module "eks_vclipper" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.27.1"
  vpc_id                          = data.terraform_remote_state.vpc.outputs.vpc_id
  cluster_name                    = join("-", [data.terraform_remote_state.global.outputs.project_name, "cluster"])
  cluster_version                 = "1.32"
  subnet_ids                      = data.terraform_remote_state.vpc.outputs.private_subnets
  cluster_security_group_id       = data.terraform_remote_state.security_group_vclipper.outputs.sg_additional_vclipper_eks_id
  node_security_group_id          = data.terraform_remote_state.security_group_vclipper.outputs.sg_node_vclipper_eks_id
  create_cluster_security_group   = false
  create_node_security_group      = false
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  create_iam_role                 = "false"
  enable_irsa                     = "false"
  iam_role_arn                    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"  
  tags = {
    Provisioned  = "Terraform"
    Product      = "Hackathon"
  }
  
  #cluster_addons = {
  #  coredns = {
  #    resolve_conflicts_on_update = "NONE"
  #    resolve_conflicts_on_create = "OVERWRITE"
  #    #service_account_role_arn    = "arn:aws:iam::208016918243:role/LabRole"
  #    version                     = "v1.11.3-eksbuild.1"
  #  }
  # aws-ebs-csi-driver = {
  #    resolve_conflicts_on_update = "NONE"
  #    resolve_conflicts_on_create = "OVERWRITE"
  #    #service_account_role_arn    = "arn:aws:iam::208016918243:role/LabRole"
  #    version                     = "v1.41.0-eksbuild.1"
  #  }
  #}

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 50
    instance_types = ["t2.micro", "t3.large"]
  }

  eks_managed_node_groups = {
    application = {
      name                    = "ng-vclipper-app"
      min_size                = 2
      max_size                = 5
      desired_size            = 2
      instance_types          = ["t3.large"]
      create_iam_role         = "false"
      iam_role_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
       

      labels = {
        application = "vclipper-app"
      }

      tags = {
        Provisioned  = "Terraform"
        Product      = "Hackathon"
      }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 30
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 125
            encrypted             = false
            delete_on_termination = true
          }
        }
      }
    }
  } 
}

# Node Group Scale Up
resource "aws_autoscaling_policy" "eks_autoscaling_policy-up" {
  count = length(module.eks_vclipper.eks_managed_node_groups)

  name                   = "${module.eks_vclipper.eks_managed_node_groups_autoscaling_group_names[count.index]}-eks_autoscaling_policy-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = module.eks_vclipper.eks_managed_node_groups_autoscaling_group_names[count.index]
}

resource "aws_cloudwatch_metric_alarm" "eks-node-group-up" {
  count = length(module.eks_vclipper.eks_managed_node_groups)

  alarm_name          = "${module.eks_vclipper.eks_managed_node_groups_autoscaling_group_names[count.index]}-eks-node-group-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = module.eks_vclipper.eks_managed_node_groups_autoscaling_group_names[count.index]
  }
  alarm_actions     = [aws_autoscaling_policy.eks_autoscaling_policy-up[count.index].arn]
  alarm_description = "This metric monitors the CPU usage of the autoscaling group machines"
}

# Node Group Scale Down
resource "aws_autoscaling_policy" "eks_autoscaling_policy-down" {
  count = length(module.eks_vclipper.eks_managed_node_groups)

  name                   = "${module.eks_vclipper.eks_managed_node_groups_autoscaling_group_names[count.index]}-eks_autoscaling_policy-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = module.eks_vclipper.eks_managed_node_groups_autoscaling_group_names[count.index]
}

resource "aws_cloudwatch_metric_alarm" "eks-node-group-down" {
  count = length(module.eks_vclipper.eks_managed_node_groups)

  alarm_name          = "${module.eks_vclipper.eks_managed_node_groups_autoscaling_group_names[count.index]}-eks-node-group-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = module.eks_vclipper.eks_managed_node_groups_autoscaling_group_names[count.index]
  }
  alarm_actions     = [aws_autoscaling_policy.eks_autoscaling_policy-down[count.index].arn]
  alarm_description = "This metric monitors the CPU usage of the autoscaling group machines"
}

