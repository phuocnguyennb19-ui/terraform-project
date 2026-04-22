variable "global_config" {
  description = "Global configuration from config.yml"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "config_file" {
  description = "The name of the configuration file to load"
  type        = string
  default     = "config.yml"
}

variable "manual_config" {
  description = "Manual configuration to override file config"
  type        = any
  default     = {}
}
