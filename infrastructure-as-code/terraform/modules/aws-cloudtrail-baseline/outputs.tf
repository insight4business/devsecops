output "trail_arn" {
  description = "CloudTrail trail ARN."
  value       = aws_cloudtrail.this.arn
}

output "log_bucket_id" {
  description = "Log bucket name."
  value       = aws_s3_bucket.logs.id
}

output "kms_key_arn" {
  description = "KMS key ARN used for the logs (null when none)."
  value       = local.kms_arn
}
