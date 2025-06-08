# terraform/modules/frontend/main.tf

# S3 bucket para hosting estático
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend-${var.environment}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-frontend-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    Service     = "frontend"
    ManagedBy   = "terraform"
  }
}

# Sufijo aleatorio para evitar conflictos de nombres de bucket
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Configuración de website
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Bloquear acceso público por defecto (usaremos políticas específicas)
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Política de bucket para acceso público de lectura
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  depends_on = [aws_s3_bucket_public_access_block.frontend]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

# Configuración de versionado (solo para prod)
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = var.environment == "prod" ? "Enabled" : "Suspended"
  }
}

# Configuración de servidor
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CORS configuration para API calls
resource "aws_s3_bucket_cors_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Lifecycle configuration para ahorrar costes
resource "aws_s3_bucket_lifecycle_configuration" "frontend" {
  count  = var.environment == "prod" ? 1 : 0
  bucket = aws_s3_bucket.frontend.id

  rule {
    id     = "delete_old_versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# IAM role para CI/CD deploy
resource "aws_iam_role" "frontend_deploy_role" {
  name = "${var.project_name}-frontend-deploy-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-frontend-deploy-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Política para deploy en S3
resource "aws_iam_policy" "frontend_deploy_policy" {
  name        = "${var.project_name}-frontend-deploy-policy-${var.environment}"
  description = "Policy for GitHub Actions to deploy to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.frontend.arn,
          "${aws_s3_bucket.frontend.arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-frontend-deploy-policy-${var.environment}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Adjuntar política al role
resource "aws_iam_role_policy_attachment" "frontend_deploy_policy_attachment" {
  role       = aws_iam_role.frontend_deploy_role.name
  policy_arn = aws_iam_policy.frontend_deploy_policy.arn
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}