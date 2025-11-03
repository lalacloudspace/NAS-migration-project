# --------------------------
# IAM Module Outputs
# --------------------------
output "cloudspace_group_arn" {
  value = module.iam.cloudspace_group_arn # this is how you reference module outputs in root outputs.tf 
}                                         # (module.<module_name>.<output_name>)

output "nas_security_group_arn" {
  value = module.iam.nas_security_group_arn
}

output "nas_operations_group_arn" {
  value = module.iam.nas_operations_group_arn
}

# --------------------------
# Network Module Outputs
# --------------------------
output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

# --------------------------
# Static Website Module Outputs
# --------------------------
# Show the CloudFront default domain
output "cloudfront_domain" {
  value = module.static_site.cloudfront_url
}

# Show the custom domain
output "static_site_url" {
  value = module.static_site.website_url
}

#
# ✅ Corrected Root outputs.tf

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.dynamic_web.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.dynamic_web.alb_arn
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.dynamic_web.alb_zone_id
}
