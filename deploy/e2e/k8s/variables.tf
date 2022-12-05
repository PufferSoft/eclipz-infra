variable "region" {
  description = "AWS region to create resources in"
  type  = string
}

variable "namespace" {
    description = "Namespace to deploy the admin gui"
    type = string
}

variable "repo_url" {
  description = "Admingui  repository URL"
  type = string
}

variable "frontend_repo_path" {
  description = "Admingui frontend repository path"
  type = string
}

variable "backend_repo_path" {
  description = "Admingui backend repository path"
  type = string
}

variable "controller_repo_path" {
  description = "Admingui controller repository path"
  type = string
}

variable "github_secret_arn" {
  description = "[Temoprary] Github secret"
  type = string
}

variable "tf_state_eks_s3_bucket" {
  type        = string
  description = "Terraform state S3 Bucket Name"
}

variable "tf_state_eks_s3_key" {
  type        = string
  description = "Terraform state S3 Key path"
}

variable "ssl_certificate_arn" {
  type = string
  description = "AWS SSL certificate ARN"
}