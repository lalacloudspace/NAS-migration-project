# ✅ Corrected modules/Dynamic-web/outputs.tf

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.alb.arn
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.alb.zone_id
}
