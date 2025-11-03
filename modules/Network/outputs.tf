output "vpc_id" {
  value = aws_vpc.main_vpc.id # Output the VPC ID
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id # Return a list of all public subnet IDs
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id # Return a list of all private subnet IDs
}
