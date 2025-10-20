##########################
# Outputs
##########################

output "environment" {
  description = "Environment name"
  value       = local.environment
}

output "region" {
  description = "AWS Region"
  value       = local.region
}

output "account_id" {
  description = "AWS Account ID"
  value       = local.account_id
}

output "s3_kms_key_id" {
  description = "KMS Key ID for S3 encryption"
  value       = aws_kms_key.s3_kms.key_id
}

output "s3_kms_key_arn" {
  description = "KMS Key ARN for S3 encryption"
  value       = aws_kms_key.s3_kms.arn
}

# S3 Bucket outputs
output "s3_glue_job_bucket_name" {
  description = "Name of the Glue jobs bucket"
  value       = try(module.s3_glue_job_bucket.bucket_name, null)
}

output "s3_raw_archive_bucket_name" {
  description = "Name of the raw archive bucket"
  value       = try(module.s3_raw_archive_bucket.bucket_name, null)
}

output "s3_raw_bucket_name" {
  description = "Name of the raw zone bucket"
  value       = try(module.s3_raw_bucket.bucket_name, null)
}

output "s3_structured_bucket_name" {
  description = "Name of the structured zone bucket"
  value       = try(module.s3_structured_bucket.bucket_name, null)
}

output "s3_curated_bucket_name" {
  description = "Name of the curated zone bucket"
  value       = try(module.s3_curated_bucket.bucket_name, null)
}

output "s3_temp_reload_bucket_name" {
  description = "Name of the temp reload bucket"
  value       = try(module.s3_temp_reload_bucket.bucket_name, null)
}

output "s3_domain_bucket_name" {
  description = "Name of the domain bucket"
  value       = try(module.s3_domain_bucket.bucket_name, null)
}

output "s3_schema_registry_bucket_name" {
  description = "Name of the schema registry bucket"
  value       = try(module.s3_schema_registry_bucket.bucket_name, null)
}

output "s3_domain_config_bucket_name" {
  description = "Name of the domain config bucket"
  value       = try(module.s3_domain_config_bucket.bucket_name, null)
}

output "s3_violation_bucket_name" {
  description = "Name of the violation bucket"
  value       = try(module.s3_violation_bucket.bucket_name, null)
}

output "s3_landing_bucket_name" {
  description = "Name of the landing zone bucket"
  value       = try(module.s3_landing_bucket.bucket_name, null)
}

output "s3_landing_processing_bucket_name" {
  description = "Name of the landing processing zone bucket"
  value       = try(module.s3_landing_processing_bucket.bucket_name, null)
}

output "s3_quarantine_bucket_name" {
  description = "Name of the quarantine zone bucket"
  value       = try(module.s3_quarantine_bucket.bucket_name, null)
}
