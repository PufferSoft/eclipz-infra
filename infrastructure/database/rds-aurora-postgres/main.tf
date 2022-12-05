terraform {
  required_version = ">= 0.13"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 2.2"
    }
  }
}

provider "aws" {
  region = local.region
}

locals {
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone

  name   = join("-", [local.tenant, local.environment, local.zone, "aurora"])
  region = var.region

  # VPC
  vpc_id                  = var.vpc_id
  allowed_cidr_blocks     = var.allowed_cidr_blocks
  allowed_security_groups = var.allowed_security_groups

  # DB Settings
  engine_version  = var.engine_version
  instance_class  = var.instance_class
  subnets         = var.subnets
  instances       = var.instances
  database_name   = var.database_name
  master_username = var.master_username
}

################################################################################
# RDS Aurora Module
################################################################################

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "7.2.2"

  name           = local.name
  engine         = "aurora-postgresql"
  engine_version = local.engine_version

  instance_class = local.instance_class
  instances      = local.instances

  vpc_id  = local.vpc_id
  subnets = local.subnets

  allowed_security_groups = local.allowed_security_groups
  vpc_security_group_ids  = local.allowed_security_groups
  allowed_cidr_blocks     = local.allowed_cidr_blocks

  database_name   = local.database_name
  master_username = local.master_username

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  create_security_group  = false

  # db_parameter_group_name         = "default"
  # db_cluster_parameter_group_name = "default"

  enabled_cloudwatch_logs_exports = ["postgresql"]
}
