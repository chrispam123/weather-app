# terraform/modules/api/outputs.tf

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.weather_api.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.weather_api.arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.weather_api.invoke_arn
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.weather_api.id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.weather_api.arn
}

output "api_gateway_url" {
  description = "Base URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.weather_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.environment}"
}

output "api_gateway_stage_url" {
  description = "Full URL of the API Gateway stage"
  value       = "https://${aws_api_gateway_rest_api.weather_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.environment}"
}

output "weather_endpoint_url" {
  description = "Complete weather endpoint URL"
  value       = "https://${aws_api_gateway_rest_api.weather_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.environment}/weather"
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

# Data source para obtener la región actual
data "aws_region" "current" {}