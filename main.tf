provider "aws" {
  region = var.aws_region
}

module "iam" {
  source = "./modules/iam"

  cloudspace_engineers_group_name = var.cloudspace_engineers_group_name
  nas_security_group_name         = var.nas_security_group_name
  nas_operations_group_name       = var.nas_operations_group_name

  engineers_users  = var.engineers_users
  security_users   = var.security_users
  operations_users = var.operations_users
}

module "network" {
  source = "./modules/network"
  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "static_site" {
  source = "./modules/Static-website"

  bucket_name         = var.bucket_name
  domain_name         = var.domain_name  
  hosted_zone_id      = var.hosted_zone_id 
  acm_certificate_arn = var.acm_certificate_arn
}

# --- DYNAMIC WEB MODULE ---
module "dynamic_web" {
  source = "./modules/Dynamic-web"

  # ---------- Project and Environment ----------
  project_name = var.project_name
  environment  = var.environment
  region       = var.aws_region
  domain_name_root = var.domain_name_root
  hosted_zone_id   = var.hosted_zone_id
  acm_certificate_arn = var.acm_certificate_arn
  # ---------- Network ----------
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  cidr_ipv4          = var.alb_allowed_cidrs

  # ---------- IAM Policy ARNs ----------
  ssm_policy_arn        = var.ssm_policy_arn
  efs_policy_arn        = var.efs_policy_arn
  cloudwatch_policy_arn = var.cloudwatch_policy_arn
  ssm_core_policy_arn   = var.ssm_core_policy_arn

  # ---------- Database ----------
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version
  db_instance_class = var.db_instance_class
  db_multi_az       = var.db_multi_az

  # ---------- Auto Scaling ----------
  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  # ---------- ALB / Security ----------
  alb_allowed_cidrs = var.alb_allowed_cidrs
  enable_https      = var.enable_https

  # ---------- EC2 / Compute ----------
  instance_type = var.instance_type
}