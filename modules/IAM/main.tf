############################
# 1. CloudSpace Engineers
############################
resource "aws_iam_group" "cloudspace_engineers" {
  name = var.cloudspace_engineers_group_name
}

resource "aws_iam_policy" "cloudspace_policy" {
  name        = "${var.cloudspace_engineers_group_name}Policy"
  description = "Full admin access except billing"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      },
      {
        Effect = "Deny",
        Action = [
          "aws-portal:*",
          "cur:*",
          "ce:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "attach_cloudspace" {
  group      = aws_iam_group.cloudspace_engineers.name
  policy_arn = aws_iam_policy.cloudspace_policy.arn
}

# Users for Engineers Group
resource "aws_iam_user" "engineers_users" {
  for_each = toset(var.engineers_users)
  name     = lower(each.value)
}

resource "aws_iam_user_group_membership" "engineers_membership" {
  for_each = toset(var.engineers_users)
  user     = aws_iam_user.engineers_users[each.key].name
  groups   = [aws_iam_group.cloudspace_engineers.name]
}

############################
# 2. NAS Security Team
############################
resource "aws_iam_group" "nas_security_team" {
  name = var.nas_security_group_name
}

resource "aws_iam_policy" "nas_security_policy" {
  name        = "${var.nas_security_group_name}Policy"
  description = "Full admin and billing access for Security Team"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "attach_security" {
  group      = aws_iam_group.nas_security_team.name
  policy_arn = aws_iam_policy.nas_security_policy.arn
}

resource "aws_iam_user" "security_users" {
  for_each = toset(var.security_users)
  name     = lower(each.value)
}

resource "aws_iam_user_group_membership" "security_membership" {
  for_each = toset(var.security_users)
  user     = aws_iam_user.security_users[each.key].name
  groups   = [aws_iam_group.nas_security_team.name]
}

############################
# 3. NAS Operations Team
############################
resource "aws_iam_group" "nas_operations_team" {
  name = var.nas_operations_group_name
}

resource "aws_iam_policy" "nas_operations_policy" {
  name        = "${var.nas_operations_group_name}Policy"
  description = "Allow full admin only in us-east-1 region"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "*",
        Resource = "*",
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "us-east-1"
          }
        }
      },
      {
        Effect = "Deny",
        Action = "*",
        Resource = "*",
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = "us-east-1"
          }
        }
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "attach_operations" {
  group      = aws_iam_group.nas_operations_team.name
  policy_arn = aws_iam_policy.nas_operations_policy.arn
}

resource "aws_iam_user" "operations_users" {
  for_each = toset(var.operations_users)
  name     = lower(each.value)
}

resource "aws_iam_user_group_membership" "operations_membership" {
  for_each = toset(var.operations_users)
  user     = aws_iam_user.operations_users[each.key].name
  groups   = [aws_iam_group.nas_operations_team.name]
}

