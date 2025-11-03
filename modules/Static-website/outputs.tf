# CloudFront URL (default domain from AWS)
output "cloudfront_url" {
  value       = aws_cloudfront_distribution.cf.domain_name
  description = "CloudFront distribution URL"
}

# Custom domain URL
output "website_url" {
  value       = "https://${var.domain_name}"
  description = "Custom domain for the static website"
}

# S3 bucket name
output "bucket_name" {
  value       = aws_s3_bucket.static_site.bucket
  description = "Name of the S3 bucket"
}
