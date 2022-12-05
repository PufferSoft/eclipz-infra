#############################
# EKS Cluster
#############################
output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks-cluster-with-import-vpc.eks_cluster_id
  depends_on = [
    module.eks-cluster-with-import-vpc
  ]
}

output "certificate_authority_data" {
  description = "Cluster certificate authority data"
  value       = module.eks-cluster-with-import-vpc.eks_cluster_certificate_authority_data
  sensitive = true
  depends_on = [
    module.eks-cluster-with-import-vpc
  ]
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.eks-cluster-with-import-vpc.eks_cluster_endpoint
  depends_on = [
    module.eks-cluster-with-import-vpc
  ]
}
#################################
# RDS connection info
#################################

output "db_password" {
  description = "Cluster master password"
  value       = module.rds_postgres.cluster_master_password
  sensitive = true
}

output "db_username" {
  description = "Cluster master username"
  value       = module.rds_postgres.cluster_master_username
  sensitive = true
}

output "db_port" {
  description = "Cluster port"
  value       = module.rds_postgres.cluster_port
}

output "db_endpoint" {
    description = "Cluster writer endpoint"
    value = module.rds_postgres.cluster_endpoint
}

output "db_name" {
    description = "Name for an automatically created database on cluster creation"
    value = module.rds_postgres.cluster_database_name
}


# output "node_security_group_id" {
#   description = "Cluster node security group id"
#   value       = module.eks_blueprints.worker_node_security_group_id
# }
