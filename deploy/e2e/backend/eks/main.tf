########################################
# AWS Terraform backend composition
########################################

module "terraform_remote_backend" {
  source   = "../../../../infrastructure/terraform_remote_backend"
#  env      = var.env
  environment      = var.environment
  zone = var.zone
  region   = var.region
  tags     = local.tags
  tenant      = var.tenant

  ########################################
  ## Terraform State S3 Bucket
  ########################################
  acl                = var.acl # infra's input var = composition's input var, coming from .tfvars
  force_destroy      = var.force_destroy
  versioning_enabled = var.versioning_enabled

  ## s3 bucket public access block ##
  block_public_policy     = var.block_public_policy
  block_public_acls       = var.block_public_acls
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets

  ########################################
  ## DynamoDB
  ########################################
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key
  attribute_name = var.attribute_name
  attribute_type = var.attribute_type
  sse_enabled    = var.sse_enabled
}
