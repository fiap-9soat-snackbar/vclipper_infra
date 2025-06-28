output "eks_vclipper_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks_vclipper.cluster_endpoint
}

output "eks_vclipper_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks_vclipper.cluster_security_group_id
}

output "worker_eks_vclipper_security_group_id" {
  description = "Security group ids attached to the workers."
  value       = module.eks_vclipper.node_security_group_id
}

output "vclipper_id" {
  description = "token for eks"
  value = module.eks_vclipper.cluster_id
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "ASG nodeGroups names"
  value = module.eks_vclipper.eks_managed_node_groups_autoscaling_group_names
}

output "Managed_groups" {
  value = module.eks_vclipper.eks_managed_node_groups_autoscaling_group_names

}
