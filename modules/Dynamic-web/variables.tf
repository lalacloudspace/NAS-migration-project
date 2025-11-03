# =============================================================
# 📦 VARIABLES - CHILD MODULE (Dynamic Web)
# Purpose: Define inputs for VPC, DB, ALB, IAM, and ASG components
# =============================================================

# ---------- Project and Environment ----------
variable "project_name" { 
  description = "The name of the project (e.g., nas)"
  type        = string 
}

variable "environment"  { 
  description = "Deployment environment (e.g., dev, prod)"
  type        = string 
}

variable "region" { 
  description = "AWS region where resources are deployed"
  type        = string 
}

variable "domain_name_root" { 
  description = "Root domain name for ACM certificate lookup"
  type        = string 
}

# ---------- Network ----------
variable "vpc_id" { 
  description = "VPC ID from the Network module"
  type        = string 
}

variable "public_subnet_ids" { 
  description = "List of public subnet IDs from the Network module"
  type        = list(string) 
}

variable "private_subnet_ids" { 
  description = "List of private subnet IDs from the Network module"
  type        = list(string) 
}

variable "cidr_ipv4" { 
  description = "CIDR block(s) for IPv4"
  type        = list(string) 
}

# ---------- IAM Policy ARNs ----------
variable "ssm_policy_arn" { 
  description = "ARN for the SSM policy (FullAccess or ManagedInstanceCore)"
  type        = string 
}
variable "ssm_core_policy_arn" { 
  description = "ARN for the SSM policy"
  type        = string 
}


variable "efs_policy_arn" { 
  description = "ARN for the EFS access policy"
  type        = string 
}

variable "cloudwatch_policy_arn" { 
  description = "ARN for the CloudWatch Agent policy"
  type        = string 
}

# ---------- Database Configuration ----------
variable "db_name" { 
  description = "Database name for WordPress"
  type        = string 
}

variable "db_username" { 
  description = "Database admin username"
  type        = string 
}

variable "db_password" { 
  description = "Database admin password"
  type        = string 
  sensitive   = true 
}

variable "db_engine" { 
  description = "Database engine (e.g., mysql)"
  type        = string 
}

variable "db_engine_version" { 
  description = "Database engine version (e.g., 8.0)"
  type        = string 
}

variable "db_instance_class" { 
  description = "Instance class for the RDS (e.g., db.t3.micro)"
  type        = string 
}

variable "db_multi_az" { 
  description = "Enable Multi-AZ RDS deployment"
  type        = bool 
}

# ---------- Auto Scaling Configuration ----------
variable "desired_capacity" { 
  description = "Desired number of EC2 instances in Auto Scaling Group"
  type        = number 
}

variable "min_size" { 
  description = "Minimum number of EC2 instances"
  type        = number 
}

variable "max_size" { 
  description = "Maximum number of EC2 instances"
  type        = number 
}

# ---------- ALB / Security ----------
variable "alb_allowed_cidrs" { 
  description = "Allowed CIDRs to access the ALB (e.g., [\"0.0.0.0/0\"])"
  type        = list(string) 
}

variable "enable_https" { 
  description = "Enable HTTPS listener (true/false)"
  type        = bool 
}

# ---------- EC2 / Compute ----------
variable "instance_type" { 
  description = "EC2 instance type for web servers (e.g., t3.micro)"
  type        = string 
}
variable "hosted_zone_id" {
  type        = string
  description = "Hosted zone ID for Route 53 domain"
}
variable "acm_certificate_arn" {
  description = "ARN of the existing ACM certificate"
  type        = string
}
