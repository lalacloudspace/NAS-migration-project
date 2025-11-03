# --------------------------
# S3 Bucket for Static Website
# --------------------------
resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name  # ✅ Use variable directly, no quotes

  tags = {
    Name = var.bucket_name
  }
}

# Block Public Access to S3 (Only CloudFront can access)
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload index.html to S3
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "index.html"
  content_type = "text/html"
  source       = "${path.module}/index.html"
}

# --------------------------
# CloudFront Origin Access Control (OAC)
# --------------------------
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.bucket_name}-oac"
  description                       = "OAC for static website"
  origin_access_control_origin_type = "s3"
  signing_protocol                  = "sigv4"
  signing_behavior                  = "always"
}

# --------------------------
# CloudFront Distribution
# --------------------------
resource "aws_cloudfront_distribution" "cf" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = "${aws_s3_bucket.static_site.bucket}.s3.amazonaws.com"
    origin_id                = "s3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "StaticRestrictedSite"
  }
}
# Route 53 DNS Record → CloudFront
resource "aws_route53_record" "static_site_record" {
  zone_id = var.hosted_zone_id              # ✅ Existing Hosted Zone
  name    = var.domain_name                 # "restricted.nasfinancial.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = false
  }
}
