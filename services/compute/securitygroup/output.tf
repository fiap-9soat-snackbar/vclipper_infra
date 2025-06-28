## Additional vclipper

output "sg_additional_vclipper_eks_id" {
  description = "The ID of the security group"
  value       = module.sg_additional_vclipper_eks.security_group_id
}

output "sg_additional_vclipper_eks_name" {
  description = "The name of the security group"
  value       = module.sg_additional_vclipper_eks.security_group_name
}


## Node vclipper

output "sg_node_vclipper_eks_id" {
  description = "The ID of the security group"
  value       = module.sg_node_vclipper_eks.security_group_id
}

output "sg_node_vclipper_eks_name" {
  description = "The name of the security group"
  value       = module.sg_node_vclipper_eks.security_group_name
}