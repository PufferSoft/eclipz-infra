output "repository_url_map" {
  value = zipmap(
    values(module.ecr)[*].repository_registry_id,
    values(module.ecr)[*].repository_url
  )
  description = "Map of repository names to repository URLs"
}
