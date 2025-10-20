##################
### S3 Buckets ###
##################
# S3 Glue Jobs
module "s3_glue_job_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-glue-jobs-${local.environment}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-glue-jobs-${local.environment}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "dwh-108"
    }
  )
}

# S3 Raw Archive
module "s3_raw_archive_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-raw-archive-${local.env}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-raw-archive-${local.env}-s3"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "DPR2-209"
    }
  )
}
# S3 RAW
module "s3_raw_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-raw-zone-${local.env}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-raw-zone-${local.env}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "dwh-108"
    }
  )
}

# S3 Structured
module "s3_structured_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-structured-zone-${local.env}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-structured-zone-${local.env}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "dwh-108"
    }
  )
}

# S3 Curated
module "s3_curated_bucket" {
  source                     = "./modules/s3_bucket"
  create_s3                  = local.setup_buckets
  name                       = "${local.project}-curated-zone-${local.env}"
  custom_kms_key             = local.s3_kms_arn
  create_notification_queue  = false # For SQS Queue
  enable_lifecycle           = true
  enable_intelligent_tiering = false

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-curated-zone-${local.env}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "dwh-108"
    }
  )
}

# S3 Temp Reload
module "s3_temp_reload_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-temp-reload-${local.env}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-temp-reload-${local.env}"
      dwh-resource-type = "S3 Bucket",
      dwh-jira          = "DPR2-46"
    }
  )
}

# Data Domain Bucket
module "s3_domain_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-domain-${local.env}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-domain-${local.env}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "dwh-108"
    }
  )
}

# Schema Registry Bucket
module "s3_schema_registry_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-schema-registry-${local.env}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true
  enable_s3_versioning      = true
  enable_versioning_config  = "Enabled"

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-schema-registry-${local.env}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "DPR2-245"
    }
  )
}

# Data Domain Configuration Bucket
module "s3_domain_config_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-domain-config-${local.env}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-domain-config-${local.env}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "dwh-108"
    }
  )
}

# S3 Violation Zone Bucket, dwh-318/dwh-301
module "s3_violation_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-violation-${local.environment}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-violation-${local.environment}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "dwh-108"
    }
  )
}

# S3 Landing Zone Bucket. Used by File Transfer In/Push
module "s3_landing_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-landing-zone-${local.environment}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-landing-zone-${local.environment}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "DPR2-1499"
    }
  )
}

# S3 Landing Processing Zone Bucket. Used by File Transfer In/Push
module "s3_landing_processing_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-landing-processing-zone-${local.environment}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-landing-processing-zone-${local.environment}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "DPR2-1499"
    }
  )
}

# S3 Quarantine Zone Bucket. Used by File Transfer In/Push
module "s3_quarantine_bucket" {
  source                    = "./modules/s3_bucket"
  create_s3                 = local.setup_buckets
  name                      = "${local.project}-quarantine-zone-${local.environment}"
  custom_kms_key            = local.s3_kms_arn
  create_notification_queue = false # For SQS Queue
  enable_lifecycle          = true

  tags = merge(
    local.all_tags,
    {
      dwh-name          = "${local.project}-quarantine-zone-${local.environment}"
      dwh-resource-type = "S3 Bucket"
      dwh-jira          = "DPR2-1499"
    }
  )
}

# S3 Bucket (Application Artifacts Store)
# Commented out initially - requires Lambda function to be created first
# module "s3_artifacts_store" {
#   source              = "./modules/s3_bucket"
#   create_s3           = local.setup_buckets
#   name                = "${local.project}-artifact-store-${local.environment}"
#   custom_kms_key      = local.s3_kms_arn
#   enable_notification = true
#
#   # Dynamic, supports multiple notifications blocks
#   bucket_notifications = {
#     "lambda_function_arn" = module.domain_builder_flyway_Lambda.lambda_function
#     "events"              = ["s3:ObjectCreated:*"]
#     "filter_prefix"       = "build-artifacts/domain-builder/jars/"
#     "filter_suffix"       = ".jar"
#   }
#
#   dependency_lambda = [module.domain_builder_flyway_Lambda.lambda_function] # Required if bucket_notications is enabled
#
#   tags = merge(
#     local.all_tags,
#     {
#       dwh-name          = "${local.project}-artifact-store-${local.environment}"
#       dwh-resource-type = "S3 Bucket"
#       dwh-jira          = "dwh-108"
#     }
#   )
# }

# S3 Working Bucket
# Commented out initially - requires s3_redshift_table_expiry_days variable
# module "s3_working_bucket" {
#   source                    = "./modules/s3_bucket"
#   create_s3                 = local.setup_buckets
#   name                      = "${local.project}-working-${local.environment}"
#   custom_kms_key            = local.s3_kms_arn
#   create_notification_queue = false # For SQS Queue
#   enable_lifecycle          = true
#   lifecycle_category        = "long_term"
#
#   override_expiration_rules = [
#     {
#       id     = "reports"
#       prefix = "reports/"
#       days   = local.s3_redshift_table_expiry_days
#     },
#     {
#       id     = "dpr"
#       prefix = "dpr/"
#       days   = 7
#     }
#   ]
#
#   tags = merge(
#     local.all_tags,
#     {
#       dwh-name          = "${local.project}-working-${local.environment}"
#       dwh-resource-type = "S3 Bucket"
#       dwh-jira          = "dwh-108"
#     }
#   )
# }
