# terraform/modules/frontend/variables.tf

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

variable "github_repository" {
  description = "GitHub repository in format 'owner/repo' for OIDC"
  type        = string
  default     = ""
}

variable "api_gateway_url" {
  description = "API Gateway URL for frontend configuration"
  type        = string
  default     = ""
}

variable "enable_build_notifications" {
  description = "Enable S3 notifications for build triggers"
  type        = bool
  default     = false
}

variable "create_example_files" {
  description = "Create example HTML files for testing"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable S3 versioning (automatic for prod)"
  type        = bool
  default     = null
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "lifecycle_rule_enabled" {
  description = "Enable lifecycle rules for cost optimization"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep non-current versions"
  type        = number
  default     = 30
  validation {
    condition     = var.noncurrent_version_expiration_days > 0 && var.noncurrent_version_expiration_days <= 365
    error_message = "Expiration days must be between 1 and 365."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}