output "role_name" {
  description = "Name of the IAM role"
  value       = var.create_role ? aws_iam_role.this[0].name : null
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = var.create_role ? aws_iam_role.this[0].arn : null
}

output "role_id" {
  description = "ID of the IAM role"
  value       = var.create_role ? aws_iam_role.this[0].id : null
}

output "role_unique_id" {
  description = "Unique ID of the IAM role"
  value       = var.create_role ? aws_iam_role.this[0].unique_id : null
}
