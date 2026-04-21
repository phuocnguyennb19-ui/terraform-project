variable "vpc_id" {
  description = "VPC ID for same-stack orchestration"
  type        = string
  default     = null
}

variable "private_subnets" {
  description = "Subnet IDs for same-stack orchestration"
  type        = list(string)
  default     = null
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for security group ingress rules"
  type        = string
  default     = "10.0.0.0/16"
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
