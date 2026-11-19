output "instance_id" {
  description = "Instance ID. Connect with: aws ssm start-session --target <instance_id>."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address."
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Security group ID (no inbound rules)."
  value       = aws_security_group.this.id
}

output "iam_role_name" {
  description = "Instance role name; attach extra least-privilege policies here if needed."
  value       = aws_iam_role.this.name
}
