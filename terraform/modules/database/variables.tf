# terraform/modules/database/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "weather-app"
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "enable_gsi" {
  description = "Enable Global Secondary Index for timestamp queries"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Name of the TTL attribute"
  type        = string
  default     = "ttl"
}

variable "cache_ttl_minutes" {
  description = "Cache TTL in minutes"
  type        = number
  default     = 15
  validation {
    condition     = var.cache_ttl_minutes > 0 && var.cache_ttl_minutes <= 1440
    error_message = "Cache TTL must be between 1 and 1440 minutes (24 hours)."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}