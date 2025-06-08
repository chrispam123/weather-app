# terraform/modules/database/main.tf

# DynamoDB table para cache de clima
resource "aws_dynamodb_table" "weather_cache" {
  name           = "${var.project_name}-weather-cache-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"  # On-demand para ahorrar costes
  hash_key       = "city_key"
  
  attribute {
    name = "city_key"
    type = "S"
  }

  # TTL para expiración automática del cache
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  # Tags para organización y costes
  tags = {
    Name        = "${var.project_name}-weather-cache-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    Service     = "weather-cache"
    ManagedBy   = "terraform"
  }
}

# El GSI está deshabilitado por defecto para ahorrar costes
# Si se habilita en el futuro, se puede agregar como un recurso separado

# IAM role para Lambda acceder a DynamoDB
resource "aws_iam_role" "dynamodb_lambda_role" {
  name = "${var.project_name}-dynamodb-lambda-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-dynamodb-lambda-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Política IAM para operaciones DynamoDB
resource "aws_iam_policy" "dynamodb_lambda_policy" {
  name        = "${var.project_name}-dynamodb-lambda-policy-${var.environment}"
  description = "IAM policy for Lambda to access DynamoDB weather cache"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.weather_cache.arn,
          "${aws_dynamodb_table.weather_cache.arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-dynamodb-lambda-policy-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Adjuntar política al role
resource "aws_iam_role_policy_attachment" "dynamodb_lambda_policy_attachment" {
  role       = aws_iam_role.dynamodb_lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_lambda_policy.arn
}