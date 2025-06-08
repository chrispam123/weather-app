# terraform/modules/database/outputs.tf

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.weather_cache.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.weather_cache.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.weather_cache.id
}

output "lambda_role_arn" {
  description = "ARN of the IAM role for Lambda to access DynamoDB"
  value       = aws_iam_role.dynamodb_lambda_role.arn
}

output "lambda_role_name" {
  description = "Name of the IAM role for Lambda to access DynamoDB"
  value       = aws_iam_role.dynamodb_lambda_role.name
}

output "lambda_policy_arn" {
  description = "ARN of the IAM policy for DynamoDB access"
  value       = aws_iam_policy.dynamodb_lambda_policy.arn
}

output "cache_ttl_minutes" {
  description = "Cache TTL in minutes"
  value       = var.cache_ttl_minutes
}