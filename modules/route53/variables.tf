variable "manual_config" {
  description = "Manual configuration object (Alternative to config.yml)"
  type        = any
  default     = {}
}

variable "config_file" {
  description = "Name of the configuration file to load (e.g., dns.yml)"
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
