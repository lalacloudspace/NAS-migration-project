variable "aws_region" {
  type = string
}

# IAM GROUP VARIABLES
variable "cloudspace_engineers_group_name" {
  type = string
}

variable "nas_security_group_name" {
  type = string
}

variable "nas_operations_group_name" {
  type = string
}

# IAM USERS VARIABLES
variable "engineers_users" {
  type = list(string)
}

variable "security_users" {
  type = list(string)
}

variable "operations_users" {
  type = list(string)
}

# VPC NETWORK VARIABLES
variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

# STATIC WEBSITE VARIABLES
variable "bucket_name" {
  type = string
}

variable "domain_name_root" {
  description = "Main/root domain (e.g. thebbcousins.com)"
  type        = string
}
variable "domain_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

# DYNAMIC WEB MODULE VARIABLES
# ---------- PROJECT CONFIGURATION ----------
variable "project_name" {
  description = "The name of the project (e.g., nas)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}
# ---------- IAM POLICIES ----------
variable "ssm_policy_arn" {
  description = "ARN for SSM policy (FullAccess or ManagedInstanceCore)"
  type        = string
}

variable "efs_policy_arn" {
  description = "ARN for EFS access policy"
  type        = string
}

variable "cloudwatch_policy_arn" {
  description = "ARN for CloudWatch Agent policy"
  type        = string
}
variable "ssm_core_policy_arn" {
  description = "ARN for the SSM policy"
  type        = string
}

# ---------- NETWORKING ----------
# (These are outputs from the network module but declared for clarity)
# variable "vpc_id" {
#   description = "VPC ID from the Network module"
#   type        = string
# }

# variable "public_subnet_ids" {
#   description = "List of public subnet IDs from the Network module"
#   type        = list(string)
# }

# variable "private_subnet_ids" {
#   description = "List of private subnet IDs from the Network module"
#   type        = list(string)
# }

# ---------- DATABASE ----------
variable "db_name" {
  description = "Database name for WordPress or web app"
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
  description = "Database engine type"
  type        = string
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance type (e.g., db.t3.micro)"
  type        = string
}

variable "db_multi_az" {
  description = "Enable Multi-AZ RDS deployment (true/false)"
  type        = bool
}

# ---------- AUTO SCALING ----------
variable "desired_capacity" {
  description = "Number of EC2 instances desired in ASG"
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

# ---------- ALB / SECURITY ----------
variable "alb_allowed_cidrs" {
  description = "Allowed CIDRs to access ALB"
  type        = list(string)
}

variable "enable_https" {
  description = "Enable HTTPS listener on ALB"
  type        = bool
}

# ---------- COMPUTE ----------
variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
}
