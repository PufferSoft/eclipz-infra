variable "launch_template_config" {
  type = map(object({
    ami                    = string
    launch_template_os     = optional(string)
    launch_template_prefix = string
    instance_type          = optional(string)
    capacity_type          = optional(string)
    iam_instance_profile   = optional(string)
    vpc_security_group_ids = optional(list(string)) # conflicts with network_interfaces

    network_interfaces = optional(list(object({
      public_ip       = optional(bool)
      security_groups = optional(list(string))
    })))

    block_device_mappings = list(object({
      device_name           = string
      volume_type           = string
      volume_size           = string
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      kms_key_id            = optional(string)
      iops                  = optional(string)
      throughput            = optional(string)
    }))

    pre_userdata         = optional(string)
    bootstrap_extra_args = optional(string)
    post_userdata        = optional(string)
    kubelet_extra_args   = optional(string)

    http_endpoint               = optional(string)
    http_tokens                 = optional(string)
    http_put_response_hop_limit = optional(number)

    monitoring = optional(bool)
  }))
  description = "Launch template configuration"
}

variable "eks_cluster_id" {
  description = "EKS Cluster ID"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}
