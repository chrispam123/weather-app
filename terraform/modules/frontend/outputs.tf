# terraform/modules/frontend/outputs.tf

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.frontend.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "website_endpoint" {
  description = "Website endpoint URL"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "website_domain" {
  description = "Website domain"
  value       = aws_s3_bucket_website_configuration.frontend.website_domain
}

output "website_url" {
  description = "Complete website URL with https"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

output "deploy_role_arn" {
  description = "ARN of the IAM role for deployments"
  value       = aws_iam_role.frontend_deploy_role.arn
}

output "deploy_role_name" {
  description = "Name of the IAM role for deployments"
  value       = aws_iam_role.frontend_deploy_role.name
}

output "deploy_policy_arn" {
  description = "ARN of the deployment policy"
  value       = aws_iam_policy.frontend_deploy_policy.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Hosted zone ID of the S3 bucket"
  value       = aws_s3_bucket.frontend.hosted_zone_id
}