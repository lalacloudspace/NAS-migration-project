variable "cloudspace_engineers_group_name" {
  type        = string
  description = "IAM group name for CloudSpace Engineers"
}

variable "nas_security_group_name" {
  type        = string
  description = "IAM group name for NAS Security Team"
}

variable "nas_operations_group_name" {
  type        = string
  description = "IAM group name for NAS Operations Team"
}

variable "engineers_users" {
  type = list(string)
}

variable "security_users" {
  type = list(string)
}

variable "operations_users" {
  type = list(string)
}