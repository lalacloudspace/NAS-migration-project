# Monitor for unhealthy targets in the Application Load Balancer
resource "aws_cloudwatch_metric_alarm" "app_unhealthy" {
  alarm_name                = "App-Unhealthy-Targets" # This is the name of the alarm
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1                       # It will evaluate the metric every 1mn period to check for unhealthy targets
  metric_name               = "UnHealthyHostCount"    # This is the metric we are monitoring
  namespace                 = "AWS/ApplicationELB"    # The metric we are monitoring belongs to this namespace in AWS CloudWatch
  period                    = 60                      # The period (in seconds) over which the specified statistic is applied
  statistic                 = "Average"
  threshold                 = 0                       # Here 0 means if there is one or more unhealthy targets, the alarm will trigger
  alarm_description         = "Triggered when one or more instances fail ALB health checks (App Down)"
  alarm_actions             = [var.sns_topic_arn]                      # Add SNS topic ARN or other actions here
  ok_actions                = [var.sns_topic_arn]

  dimensions = {
    TargetGroup  =  var.target_group_arn_suffix
    LoadBalancer = var.load_balancer_arn_suffix
  }
}

# Monitor for 5xx errors
resource "aws_cloudwatch_metric_alarm" "app_5xx" {
  alarm_name          = "App-5xx-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Triggered when app returns 5 or more 5XX errors per minute"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]

  dimensions = {
    LoadBalancer =  var.load_balancer_arn_suffix
 }
}

# Monitor for low healthy instances
resource "aws_cloudwatch_metric_alarm" "asg_low_instances" {
  alarm_name          = "Low-Healthy-Instances"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Alert when less than one instance is serving traffic in ASG"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}