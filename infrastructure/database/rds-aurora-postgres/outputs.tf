################################
# RDS connection information
################################

output "cluster_master_password" {
  description = "Cluster master password"
  value       = module.aurora.cluster_master_password
  sensitive = true
}

output "cluster_master_username" {
  description = "Cluster master username"
  value       = module.aurora.cluster_master_username
  sensitive = true
}

output "cluster_port" {
  description = "Cluster port"
  value       = module.aurora.cluster_port
}

output "cluster_endpoint" {
    description = "Cluster writer endpoint"
    value = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
    description = "Cluster reader endpoint"
    value = module.aurora.cluster_reader_endpoint
}

output "cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = var.database_name
}