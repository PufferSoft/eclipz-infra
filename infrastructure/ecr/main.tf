locals {
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone

  _name       = join("-", [local.tenant, local.environment, local.zone, "ecr"])
  image_names = length(var.image_names) > 0 ? var.image_names : [local._name]
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "1.4.0"
  for_each = toset(local.image_names)

  repository_name = each.value
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
