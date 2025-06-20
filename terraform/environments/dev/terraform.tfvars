# terraform/environments/dev/terraform.tfvars.example

# Project configuration
project_name = "weather-app"
environment  = "dev"
aws_region   = "us-east-1"
owner        = "tu-nombre"

# Weather API configuration
weather_api_key      = "6ff75b08a20f9b9f9ed23f80348846bd"
weather_api_base_url = "https://api.openweathermap.org/data/2.5"

# GitHub configuration for CI/CD
github_repository = "chrispam123/weather-app"

# Development-specific settings
cache_ttl_minutes            = 15
lambda_timeout               = 30
lambda_memory_size           = 128
api_throttle_rate_limit      = 100
api_throttle_burst_limit     = 200
log_retention_days           = 7

# Frontend settings
create_example_files         = false
enable_build_notifications   = false
lifecycle_rule_enabled       = false
cors_allowed_origins         = ["*"]

# Database settings
enable_gsi = false