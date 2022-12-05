################################
# Cluster config
################################
variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
}

variable "environment" {
  type        = string
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "zone, e.g. dev or qa or load or ops etc..."
}

variable "region" {
  type        = string
  description = "AWS region"
}

################################
# VPC config
################################
variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "VPC CIDR blocks"
}

variable "allowed_security_groups" {
    type = list(string)
    description = "VPC allowed security groups"
}

###########################
# RDS Config
###########################

variable "engine_version" {
  description = "The database engine version. Updating this argument results in an outage"
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Instance type to use at master instance. Note: if `autoscaling_enabled` is `true`, this will be the same instance class used on instances created by autoscaling"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "List of subnet IDs used by database subnet group created"
  type        = list(string)
  default     = []
}

variable "instances" {
  description = "Map of cluster instances and any specific/overriding attributes to be created"
  type        = any
  default     = {
    one = {}
  }
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = "mydb"
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "root"
}