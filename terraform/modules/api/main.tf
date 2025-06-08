# terraform/modules/api/main.tf

# Archivo ZIP para el código Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../../backend/src"
  output_path = "${path.root}/../../backend/lambda.zip"
}

# Lambda function para weather API
resource "aws_lambda_function" "weather_api" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-weather-api-${var.environment}"
  role            = var.lambda_role_arn
  handler         = "handlers/weather.handler"
  runtime         = "nodejs18.x"
  architectures   = ["arm64"]  # Graviton2 - 20% más barato
  timeout         = 30
  memory_size     = 128      # Mínimo para ahorrar costes

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME   = var.dynamodb_table_name
      WEATHER_API_KEY       = var.weather_api_key
      WEATHER_API_BASE_URL  = var.weather_api_base_url
      CACHE_TTL_MINUTES     = var.cache_ttl_minutes
      NODE_ENV              = var.environment
      LOG_LEVEL             = var.environment == "prod" ? "warn" : "debug"
    }
  }

  tags = {
    Name        = "${var.project_name}-weather-api-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    Service     = "weather-api"
    ManagedBy   = "terraform"
  }
}

# CloudWatch Log Group para Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.weather_api.function_name}"
  retention_in_days = var.environment == "prod" ? 30 : 7  # Menos retención en dev
  
  tags = {
    Name        = "${var.project_name}-lambda-logs-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "weather_api" {
  name        = "${var.project_name}-api-${var.environment}"
  description = "Weather API for ${var.project_name} ${var.environment}"
  
  endpoint_configuration {
    types = ["REGIONAL"]  # Más barato que EDGE
  }

  tags = {
    Name        = "${var.project_name}-api-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    Service     = "api-gateway"
    ManagedBy   = "terraform"
  }
}

# Recurso /weather
resource "aws_api_gateway_resource" "weather" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  parent_id   = aws_api_gateway_rest_api.weather_api.root_resource_id
  path_part   = "weather"
}

# Recurso /weather/{city}
resource "aws_api_gateway_resource" "weather_city" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  parent_id   = aws_api_gateway_resource.weather.id
  path_part   = "{city}"
}

# Método GET para /weather/{city}
resource "aws_api_gateway_method" "get_weather" {
  rest_api_id   = aws_api_gateway_rest_api.weather_api.id
  resource_id   = aws_api_gateway_resource.weather_city.id
  http_method   = "GET"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.city" = true
  }
}

# Integración Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  resource_id = aws_api_gateway_resource.weather_city.id
  http_method = aws_api_gateway_method.get_weather.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.weather_api.invoke_arn
}

# Método OPTIONS para CORS
resource "aws_api_gateway_method" "options_weather" {
  rest_api_id   = aws_api_gateway_rest_api.weather_api.id
  resource_id   = aws_api_gateway_resource.weather_city.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Integración CORS
resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  resource_id = aws_api_gateway_resource.weather_city.id
  http_method = aws_api_gateway_method.options_weather.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Response CORS
resource "aws_api_gateway_method_response" "cors_response" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  resource_id = aws_api_gateway_resource.weather_city.id
  http_method = aws_api_gateway_method.options_weather.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  resource_id = aws_api_gateway_resource.weather_city.id
  http_method = aws_api_gateway_method.options_weather.http_method
  status_code = aws_api_gateway_method_response.cors_response.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Response para GET
resource "aws_api_gateway_method_response" "get_weather_response" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  resource_id = aws_api_gateway_resource.weather_city.id
  http_method = aws_api_gateway_method.get_weather.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Permiso para API Gateway invocar Lambda
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.weather_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.weather_api.execution_arn}/*/*"
}

# Deployment
resource "aws_api_gateway_deployment" "weather_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.cors_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  
  lifecycle {
    create_before_destroy = true
  }
}

# Stage personalizado con throttling
resource "aws_api_gateway_stage" "weather_api_stage" {
  deployment_id = aws_api_gateway_deployment.weather_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.weather_api.id
  stage_name    = var.environment

  tags = {
    Name        = "${var.project_name}-api-stage-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Method settings para rate limiting
resource "aws_api_gateway_method_settings" "weather_api_settings" {
  rest_api_id = aws_api_gateway_rest_api.weather_api.id
  stage_name  = aws_api_gateway_stage.weather_api_stage.stage_name
  method_path = "*/*"

  settings {
    throttling_rate_limit  = var.environment == "prod" ? 1000 : 100
    throttling_burst_limit = var.environment == "prod" ? 2000 : 200
    logging_level          = "OFF"
    data_trace_enabled     = false
    metrics_enabled        = true
  }
}