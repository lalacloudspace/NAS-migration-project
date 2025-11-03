output "cloudspace_group_arn" {
  value = aws_iam_group.cloudspace_engineers.arn
}

output "nas_security_group_arn" {
  value = aws_iam_group.nas_security_team.arn
}

output "nas_operations_group_arn" {
  value = aws_iam_group.nas_operations_team.arn
}
