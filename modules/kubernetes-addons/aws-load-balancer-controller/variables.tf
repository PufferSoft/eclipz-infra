variable "helm_config" {
  type        = any
  description = "Helm provider config for the aws_load_balancer_controller."
  default     = {}
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "addon_context" {
  type = object({
    aws_caller_identity_account_id = string
    aws_caller_identity_arn        = string
    aws_eks_cluster_endpoint       = string
    aws_partition_id               = string
    aws_region_name                = string
    eks_cluster_id                 = string
    eks_oidc_issuer_url            = string
    eks_oidc_provider_arn          = string
    tags                           = map(string)
    irsa_iam_role_path             = string
    irsa_iam_permissions_boundary  = string
  })
  description = "Input configuration for the addon"
}

variable "ssl_certificate_arn"{
type= string
default="arn:aws:acm:us-west-2:516256549202:certificate/71ba69b0-d2fb-44d4-a03e-5b5f98d3da3b"  
}

variable "domain_name"{
type= string
default="eclipzit.net"
}
