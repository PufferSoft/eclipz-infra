output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${data.aws_region.current.id} update-kubeconfig --name ${module.aws-eks-accelerator-for-terraform.eks_cluster_id}"
}

################################
# EKS Config
################################

output "eks_cluster_id" {
  description = "Amazon EKS Cluster Name"
  value       = try(module.aws-eks-accelerator-for-terraform.eks_cluster_id, "EKS Cluster not enabled")
}

output "eks_cluster_certificate_authority_data" {
  description = "Cluster certificate authority data"
  value       = module.aws-eks-accelerator-for-terraform.eks_cluster_certificate_authority_data
}

output "eks_cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.aws-eks-accelerator-for-terraform.eks_cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS Control Plane Security Group ID"
  value       = try(module.aws-eks-accelerator-for-terraform.cluster_security_group_id, "EKS Cluster not enabled")
}

output "eks_worker_security_group_id" {
  description = "EKS Control Plane Security Group ID"
  value       = try(module.aws-eks-accelerator-for-terraform.worker_node_security_group_id, "EKS Cluster not enabled")
}

#############################
# VPC Config
#############################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.aws_vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.aws_vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.aws_vpc.public_subnets
}

output "cidr_block" {
  description = "List of CIDR of public subnets"
  value       = local.vpc_cidr
}
