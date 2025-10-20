##########################
# KMS Key for S3 Encryption
##########################
resource "aws_kms_key" "s3_kms" {
  description             = "KMS key for S3 bucket encryption in ${local.environment}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    local.all_tags,
    {
      Name              = "${local.project}-s3-kms-${local.environment}"
      dwh-name          = "${local.project}-s3-kms-${local.environment}"
      dwh-resource-type = "KMS Key"
    }
  )
}

resource "aws_kms_alias" "s3_kms_alias" {
  name          = "alias/${local.project}-s3-kms-${local.environment}"
  target_key_id = aws_kms_key.s3_kms.key_id
}
