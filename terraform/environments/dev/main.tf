# terraform/environments/dev/main.tf

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }

  # Backend para almacenar el state en S3 (comentado inicialmente)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "weather-app/dev/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Provider AWS
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}

# Variables locales
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
  }
}

# Módulo Database (DynamoDB)
module "database" {
  source = "../../modules/database"
  
  project_name        = var.project_name
  environment         = var.environment
  enable_gsi          = var.enable_gsi
  cache_ttl_minutes   = var.cache_ttl_minutes
  additional_tags     = local.common_tags
}

# Módulo API (Lambda + API Gateway)
module "api" {
  source = "../../modules/api"
  
  project_name              = var.project_name
  environment               = var.environment
  lambda_role_arn           = module.database.lambda_role_arn
  dynamodb_table_name       = module.database.table_name
  weather_api_key           = var.weather_api_key
  weather_api_base_url      = var.weather_api_base_url
  cache_ttl_minutes         = var.cache_ttl_minutes
  lambda_timeout            = var.lambda_timeout
  lambda_memory_size        = var.lambda_memory_size
  api_throttle_rate_limit   = var.api_throttle_rate_limit
  api_throttle_burst_limit  = var.api_throttle_burst_limit
  log_retention_days        = var.log_retention_days
  additional_tags           = local.common_tags
  
  depends_on = [module.database]
}

# Módulo Frontend (S3)
module "frontend" {
  source = "../../modules/frontend"
  
  project_name                       = var.project_name
  environment                        = var.environment
  github_repository                  = var.github_repository
  api_gateway_url                    = module.api.weather_endpoint_url
  enable_build_notifications         = var.enable_build_notifications
  create_example_files               = var.create_example_files
  cors_allowed_origins               = var.cors_allowed_origins
  lifecycle_rule_enabled             = var.lifecycle_rule_enabled
  noncurrent_version_expiration_days = var.noncurrent_version_expiration_days
  additional_tags                    = local.common_tags
  
  depends_on = [module.api]
}