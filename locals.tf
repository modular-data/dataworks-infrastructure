locals {
  project     = var.project
  environment = var.environment
  env         = var.environment # alias for environment
  account_id  = var.account_id != "" ? var.account_id : data.aws_caller_identity.current.account_id
  region      = data.aws_region.current.name

  # S3 Configuration
  setup_buckets = var.setup_buckets
  s3_kms_arn    = aws_kms_key.s3_kms.arn

  # Common Tags
  all_tags = {
    project                = local.project
    environment            = local.environment
    environment-name       = "${local.project}-${local.environment}"
    owner                  = var.owner
    application            = var.application
    source-code            = "https://github.com/modular-data/dataworks-infrastructure"
    is-production          = local.environment == "prod" ? "true" : "false"
    business-unit          = var.business_unit
    infrastructure-support = var.owner
    terraform              = true
  }
}
