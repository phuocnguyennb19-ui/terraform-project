variable "vpc_id" {
  description = "VPC ID passed from the Master Orchestrator"
  type        = string
  default     = null
}

variable "private_subnets" {
  description = "Private Subnet IDs passed from the Master Orchestrator"
  type        = list(string)
  default     = []
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for security group rules"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_arn" {
  description = "ECS Cluster ARN passed from the Master Orchestrator"
  type        = string
  default     = null
}

variable "listener_arn" {
  description = "ALB HTTP Listener ARN for auto-attachment"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "ECS Cluster Name (legacy, prefer cluster_arn)"
  type        = string
  default     = null
}

variable "target_group_arn" {
  description = "ALB Target Group ARN (optional override)"
  type        = string
  default     = null
}

variable "image_tag" {
  description = "Tag của image container (ví dụ: v1.0.0)"
  type        = string
  default     = ""
}

variable "manual_config" {
  description = "Manual configuration object (Alternative to config.yml)"
  type        = any
  default     = {}
}

variable "config_file" {
  description = "Name of the configuration file to load (e.g., config.yml)"
  type        = string
  default     = "config.yml"
}

variable "global_config" {
  description = "Global configuration object from engine"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Standard tags from engine"
  type        = map(string)
  default     = {}
}
