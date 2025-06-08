# terraform/environments/dev/variables.tf

# Configuración general
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "weather-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "development-team"
}

# Database variables
variable "enable_gsi" {
  description = "Enable Global Secondary Index for DynamoDB"
  type        = bool
  default     = false  # Disabled in dev to save costs
}

variable "cache_ttl_minutes" {
  description = "Cache TTL in minutes"
  type        = number
  default     = 15
}

# API variables
variable "weather_api_key" {
  description = "API key for weather service"
  type        = string
  sensitive   = true
  # Will be set in terraform.tfvars
}

variable "weather_api_base_url" {
  description = "Base URL for weather API"
  type        = string
  default     = "https://api.openweathermap.org/data/2.5"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128  # Minimum for dev
}

variable "api_throttle_rate_limit" {
  description = "API Gateway throttle rate limit"
  type        = number
  default     = 100  # Lower limit for dev
}

variable "api_throttle_burst_limit" {
  description = "API Gateway throttle burst limit"
  type        = number
  default     = 200  # Lower limit for dev
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7  # Shorter retention for dev
}

# Frontend variables
variable "github_repository" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
  default     = ""  # Will be set in terraform.tfvars
}

variable "enable_build_notifications" {
  description = "Enable S3 notifications for build triggers"
  type        = bool
  default     = false
}

variable "create_example_files" {
  description = "Create example HTML files for testing"
  type        = bool
  default     = true  # Enabled for dev testing
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]  # Open CORS for dev
}

variable "lifecycle_rule_enabled" {
  description = "Enable lifecycle rules for cost optimization"
  type        = bool
  default     = false  # Disabled in dev
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep non-current versions"
  type        = number
  default     = 7  # Shorter retention for dev
}