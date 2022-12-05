variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.21"
}

variable "region" {
  type        = string
  description = "AWS region"
}

# variable "tf_state_vpc_s3_bucket" {
#   type        = string
#   description = "Terraform state S3 Bucket Name"
# }

# variable "tf_state_vpc_s3_key" {
#   type        = string
#   description = "Terraform state S3 Key path"
# }
variable "key_name"{

 type= string
 description= "key for bastion host"
 default="Elviskey"
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "aws"
}

variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
  default     = "test"
}

##########################
# Node rules
##########################

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

variable "node_security_group_additional_rules" {
  description = "Description: List of additional security group rules to add to the node security group created"
  type        = any
  default     = {}
}

#variable "profile_name" {
#  type        = string
#}
