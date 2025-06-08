# terraform/modules/api/variables.tf

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

variable "lambda_role_arn" {
  description = "ARN of the IAM role for Lambda function"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for caching"
  type        = string
}

variable "weather_api_key" {
  description = "API key for weather service (OpenWeatherMap, etc.)"
  type        = string
  sensitive   = true
}

variable "weather_api_base_url" {
  description = "Base URL for weather API"
  type        = string
  default     = "https://api.openweathermap.org/data/2.5"
}

variable "cache_ttl_minutes" {
  description = "Cache TTL in minutes"
  type        = number
  default     = 15
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 1 and 900 seconds."
  }
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory size must be between 128 and 10240 MB."
  }
}

variable "api_throttle_rate_limit" {
  description = "API Gateway throttle rate limit"
  type        = number
  default     = 100
}

variable "api_throttle_burst_limit" {
  description = "API Gateway throttle burst limit"
  type        = number
  default     = 200
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
  validation {
    condition = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}