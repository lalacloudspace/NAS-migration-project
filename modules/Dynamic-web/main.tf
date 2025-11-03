############################################################
# 🌐 DYNAMIC WEB MODULE (child) - main.tf
# Purpose: ALB + ASG + EC2 + EFS + RDS + HTTPS (ACM)
locals {
  # Builds names like: nas-dev-alb, nas-dev-web-sg, etc.
  name = "${var.project_name}-${var.environment}"
}

#############################
# 1. DATA SOURCES
#############################

# 1️⃣ Latest Amazon Linux 2023 AMI (x86_64)
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# 2️⃣ Existing ACM certificate (must already exist in us-east-1)
# data "aws_acm_certificate" "selected" {
#   domain      = var.domain_name_root
#   types       = ["AMAZON_ISSUED"]
#   statuses    = ["ISSUED"]
#   most_recent = true
# }

# # Instead, just use:
# certificate_arn = var.acm_certificate_arn

#############################
# 2. SECURITY GROUPS
#############################

# 🟢 ALB SG — public entry point
resource "aws_security_group" "alb_sg" {
  name        = "${local.name}-alb-sg"
  description = "Allow HTTP/HTTPS from Internet"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.name}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Allow HTTP (80) and HTTPS (443) from allowed CIDRs
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each          = toset(var.alb_allowed_cidrs)
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP (80) from Internet"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each          = toset(var.alb_allowed_cidrs)
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow HTTPS (443) from Internet"
}

resource "aws_vpc_security_group_egress_rule" "alb_all_outbound" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound from ALB"
}

# 🟡 WEB SG — app EC2s (only ALB can reach them)
resource "aws_security_group" "web_sg" {
  name        = "${local.name}-web-sg"
  description = "Allow HTTP only from ALB SG"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.name}-web-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_http_from_alb" {
  security_group_id             = aws_security_group.web_sg.id
  referenced_security_group_id  = aws_security_group.alb_sg.id
  from_port                     = 80
  to_port                       = 80
  ip_protocol                   = "tcp"
  description                   = "Allow HTTP from ALB only"
}

resource "aws_vpc_security_group_egress_rule" "web_all_outbound" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic from web"
}

# 🔵 EFS SG — only web servers can mount
resource "aws_security_group" "efs_sg" {
  name   = "${local.name}-efs-sg"
  vpc_id = var.vpc_id

  tags = {
    Name        = "${local.name}-efs-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "efs_allow_web" {
  security_group_id            = aws_security_group.efs_sg.id
  referenced_security_group_id = aws_security_group.web_sg.id
  from_port                    = 2049
  to_port                      = 2049
  ip_protocol                  = "tcp"
  description                  = "Allow NFS (2049) from web servers"
}

resource "aws_vpc_security_group_egress_rule" "efs_all_outbound" {
  security_group_id = aws_security_group.efs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound from EFS"
}

# 🔴 RDS SG — only web servers can reach DB
resource "aws_security_group" "rds_sg" {
  name   = "${local.name}-rds-sg"
  vpc_id = var.vpc_id

  tags = {
    Name        = "${local.name}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_allow_web" {
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = aws_security_group.web_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "Allow MySQL (3306) from web servers"
}

resource "aws_vpc_security_group_egress_rule" "rds_all_outbound" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound from RDS"
}

#############################
# 3. EFS (shared storage)
#############################
resource "aws_efs_file_system" "efs" {
  creation_token = "${local.name}-efs"
  encrypted      = true

  tags = {
    Name        = "${local.name}-efs"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_efs_mount_target" "mt" {
  for_each        = toset(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

#############################
# 4. RDS (MySQL)
#############################
resource "aws_db_subnet_group" "dbsubnet" {
  name       = "${local.name}-dbsubnet"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${local.name}-dbsubnet"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_db_instance" "db" {
  identifier              = "${local.name}-db"
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  allocated_storage       = 20
  storage_encrypted       = true
  skip_final_snapshot     = true
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.dbsubnet.name
  multi_az                = var.db_multi_az

  tags = {
    Name        = "${local.name}-db"
    Project     = var.project_name
    Environment = var.environment
  }
}

#############################
# 5. APPLICATION LOAD BALANCER
#############################
resource "aws_lb" "alb" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false

  tags = {
    Name        = "${local.name}-alb"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "${local.name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }

  tags = {
    Name        = "${local.name}-tg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# HTTP listener (always)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.enable_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.enable_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.tg.arn
    }
  }

  tags = {
    Name        = "${local.name}-http-listener"
    Project     = var.project_name
    Environment = var.environment
  }
}

# HTTPS listener (only if enabled)
resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  tags = {
    Name        = "${local.name}-https-listener"
    Project     = var.project_name
    Environment = var.environment
  }
}

#############################
# 6. IAM FOR EC2
#############################
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${local.name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = {
    Name        = "${local.name}-ec2-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.ssm_policy_arn
}
# 🟢 Add this block — it’s required for SSM connectivity
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.ssm_core_policy_arn
}

resource "aws_iam_role_policy_attachment" "efs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.efs_policy_arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.cloudwatch_policy_arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name}-profile"
  role = aws_iam_role.ec2_role.name
}

#############################
# 7. LAUNCH TEMPLATE + ASG
#############################
resource "aws_launch_template" "web" {
  name_prefix           = "${local.name}-lt-"
  image_id              = data.aws_ami.al2023.id
  instance_type         = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring { enabled = true }

  user_data = base64encode(
    templatefile("${path.module}/user_data.sh.tftpl", {
      efs_id      = aws_efs_file_system.efs.id
      db_endpoint = aws_db_instance.db.address
      db_name     = var.db_name
      db_user     = var.db_username
      region      = var.region
      db_password = var.db_password
    })
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${local.name}-web"
      Project     = var.project_name
      Environment = var.environment
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                      = "${local.name}-asg"
  desired_capacity           = var.desired_capacity
  min_size                   = var.min_size
  max_size                   = var.max_size
  vpc_zone_identifier        = var.public_subnet_ids
  target_group_arns          = [aws_lb_target_group.tg.arn]
  health_check_type          = "EC2"
  health_check_grace_period  = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#############################
# 8. ROUTE 53 ALIAS → ALB
#############################
resource "aws_route53_record" "alb_alias" {
  zone_id = var.hosted_zone_id
  name    = "app.${var.domain_name_root}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
