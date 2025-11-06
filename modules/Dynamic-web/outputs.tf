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
# --------------------------
# Additional Dynamic Web Outputs
# --------------------------

output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer"
  value       = aws_lb.alb.arn_suffix
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the Target Group"
  value       = aws_lb_target_group.tg.arn_suffix
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}
