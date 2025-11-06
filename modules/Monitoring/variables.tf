variable "sns_topic_arn" {
  description = "ARN of the SNS topic to send alarm notifications"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix"
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "Load balancer ARN suffix"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}


