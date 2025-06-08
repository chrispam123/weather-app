# terraform/environments/dev/outputs.tf

# Database outputs
output "database_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.database.table_name
}

output "database_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.database.table_arn
}

# API outputs
output "api_gateway_url" {
  description = "API Gateway base URL"
  value       = module.api.api_gateway_stage_url
}

output "weather_endpoint_url" {
  description = "Weather API endpoint URL"
  value       = module.api.weather_endpoint_url
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.api.lambda_function_name
}

# Frontend outputs
output "website_url" {
  description = "Frontend website URL"
  value       = module.frontend.website_url
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.frontend.bucket_name
}

output "deploy_role_arn" {
  description = "ARN of the deployment role for GitHub Actions"
  value       = module.frontend.deploy_role_arn
}

# Summary output for easy access
output "development_summary" {
  description = "Summary of all development environment URLs and resources"
  value = {
    frontend_url    = module.frontend.website_url
    api_url         = module.api.weather_endpoint_url
    s3_bucket       = module.frontend.bucket_name
    lambda_function = module.api.lambda_function_name
    dynamodb_table  = module.database.table_name
    deploy_role     = module.frontend.deploy_role_arn
  }
}