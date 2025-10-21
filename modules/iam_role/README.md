# IAM Role Module

This module creates an IAM role with optional pre-defined policies for common DataWorks use cases.

## Features

- Create IAM roles with custom trust policies
- Attach AWS managed policies
- Attach custom inline policies
- Pre-defined policies for:
  - S3 read + KMS read only
  - S3 read/write + KMS encrypt/decrypt
  - Glue read/write
  - Lambda read/write
  - DMS read/write

## Usage

### Example 1: Glue Job Role with S3 and KMS Access

```hcl
module "glue_job_role" {
  source = "./modules/iam_role"

  role_name = "dataworks-glue-job-role"
  description = "Role for Glue jobs to access S3 and KMS"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  # Attach pre-defined policies
  attach_s3_readwrite_kms_policy = true
  attach_glue_readwrite_policy   = true

  # Specify bucket and key ARNs
  s3_bucket_arns = [
    "arn:aws:s3:::my-data-bucket",
    "arn:aws:s3:::my-data-bucket/*"
  ]
  
  kms_key_arns = [
    "arn:aws:kms:eu-west-2:123456789012:key/abcd1234-..."
  ]

  tags = {
    Environment = "dev"
    Project     = "dataworks"
  }
}
```

### Example 2: Lambda Function Role

```hcl
module "lambda_role" {
  source = "./modules/iam_role"

  role_name = "dataworks-lambda-role"
  description = "Role for Lambda functions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  attach_lambda_readwrite_policy = true
  attach_s3_read_kms_read_policy = true

  s3_bucket_arns = ["*"]
  kms_key_arns   = ["*"]

  tags = {
    Environment = "dev"
  }
}
```

### Example 3: DMS Replication Role

```hcl
module "dms_role" {
  source = "./modules/iam_role"

  role_name = "dataworks-dms-replication-role"
  description = "Role for DMS replication tasks"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dms.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  attach_dms_readwrite_policy    = true
  attach_s3_readwrite_kms_policy = true

  s3_bucket_arns = [
    "arn:aws:s3:::dms-target-bucket",
    "arn:aws:s3:::dms-target-bucket/*"
  ]

  tags = {
    Environment = "dev"
  }
}
```

### Example 4: Multiple Policies with Custom Inline Policy

```hcl
module "data_processing_role" {
  source = "./modules/iam_role"

  role_name = "dataworks-data-processing-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["glue.amazonaws.com", "lambda.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  # Multiple pre-defined policies
  attach_s3_readwrite_kms_policy = true
  attach_glue_readwrite_policy   = true
  attach_lambda_readwrite_policy = true

  # Custom inline policy
  custom_inline_policies = {
    "secretsmanager-access" = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Resource = "arn:aws:secretsmanager:*:*:secret:dataworks/*"
        }
      ]
    })
  }

  tags = {
    Environment = "dev"
  }
}
```

## Pre-defined Policies

### 1. S3 Read + KMS Read Only
- S3: GetObject, GetObjectVersion, ListBucket, GetBucketLocation
- KMS: Decrypt, DescribeKey, GetPublicKey

### 2. S3 Read/Write + KMS
- S3: GetObject, PutObject, DeleteObject, ListBucket
- KMS: Encrypt, Decrypt, GenerateDataKey, DescribeKey

### 3. Glue Read/Write
- Full access to Glue databases, tables, jobs, crawlers, workflows
- Data catalog encryption settings

### 4. Lambda Read/Write
- Lambda function CRUD operations
- Invoke functions
- CloudWatch Logs access for Lambda

### 5. DMS Read/Write
- DMS replication instances and tasks
- Endpoints and connections
- VPC access for DMS

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| role_name | Name of the IAM role | `string` | n/a | yes |
| assume_role_policy | JSON string of the assume role policy | `string` | n/a | yes |
| description | Description of the IAM role | `string` | `""` | no |
| max_session_duration | Maximum session duration in seconds | `number` | `3600` | no |
| tags | Tags to apply to the role | `map(string)` | `{}` | no |
| managed_policy_arns | List of managed policy ARNs to attach | `list(string)` | `[]` | no |
| custom_inline_policies | Map of custom inline policies | `map(string)` | `{}` | no |
| attach_s3_read_kms_read_policy | Attach S3 read + KMS read policy | `bool` | `false` | no |
| attach_s3_readwrite_kms_policy | Attach S3 read/write + KMS policy | `bool` | `false` | no |
| attach_glue_readwrite_policy | Attach Glue read/write policy | `bool` | `false` | no |
| attach_lambda_readwrite_policy | Attach Lambda read/write policy | `bool` | `false` | no |
| attach_dms_readwrite_policy | Attach DMS read/write policy | `bool` | `false` | no |
| s3_bucket_arns | List of S3 bucket ARNs for policies | `list(string)` | `["*"]` | no |
| kms_key_arns | List of KMS key ARNs for policies | `list(string)` | `["*"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| role_name | Name of the IAM role |
| role_arn | ARN of the IAM role |
| role_id | ID of the IAM role |
| role_unique_id | Unique ID of the IAM role |

## Notes

- Always specify specific bucket ARNs and KMS key ARNs in production (avoid using `*`)
- For S3 bucket ARNs, include both the bucket ARN and bucket/* for object access
- The Lambda policy includes CloudWatch Logs permissions for function logging
- The DMS policy includes VPC access permissions for network interface management
