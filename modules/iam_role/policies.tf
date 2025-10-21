# Policy Document: S3 Read + KMS Read Only
data "aws_iam_policy_document" "s3_read_kms_read" {
  count = var.attach_s3_read_kms_read_policy ? 1 : 0

  statement {
    sid    = "S3ReadAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]
    resources = var.s3_bucket_arns
  }

  statement {
    sid    = "KMSReadAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GetPublicKey"
    ]
    resources = var.kms_key_arns
  }
}

# Policy Document: S3 Read/Write + KMS
data "aws_iam_policy_document" "s3_readwrite_kms" {
  count = var.attach_s3_readwrite_kms_policy ? 1 : 0

  statement {
    sid    = "S3ReadWriteAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]
    resources = var.s3_bucket_arns
  }

  statement {
    sid    = "KMSEncryptDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
      "kms:GetPublicKey"
    ]
    resources = var.kms_key_arns
  }
}

# Policy Document: Glue Read/Write
data "aws_iam_policy_document" "glue_readwrite" {
  count = var.attach_glue_readwrite_policy ? 1 : 0

  statement {
    sid    = "GlueReadWriteAccess"
    effect = "Allow"
    actions = [
      "glue:*Database*",
      "glue:*Table*",
      "glue:*Partition*",
      "glue:*Job*",
      "glue:*Crawler*",
      "glue:*Trigger*",
      "glue:*Workflow*",
      "glue:GetDataCatalogEncryptionSettings",
      "glue:PutDataCatalogEncryptionSettings",
      "glue:GetResourcePolicy",
      "glue:PutResourcePolicy",
      "glue:DeleteResourcePolicy"
    ]
    resources = ["*"]
  }
}

# Policy Document: Lambda Read/Write
data "aws_iam_policy_document" "lambda_readwrite" {
  count = var.attach_lambda_readwrite_policy ? 1 : 0

  statement {
    sid    = "LambdaReadWriteAccess"
    effect = "Allow"
    actions = [
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionConfiguration",
      "lambda:ListFunctions",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:InvokeFunction",
      "lambda:AddPermission",
      "lambda:RemovePermission",
      "lambda:GetPolicy",
      "lambda:TagResource",
      "lambda:UntagResource",
      "lambda:ListTags",
      "lambda:PublishVersion",
      "lambda:CreateAlias",
      "lambda:DeleteAlias",
      "lambda:GetAlias",
      "lambda:UpdateAlias"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "LambdaLogsAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*"]
  }
}

# Policy Document: DMS Read/Write
data "aws_iam_policy_document" "dms_readwrite" {
  count = var.attach_dms_readwrite_policy ? 1 : 0

  statement {
    sid    = "DMSReadWriteAccess"
    effect = "Allow"
    actions = [
      "dms:CreateReplicationInstance",
      "dms:DeleteReplicationInstance",
      "dms:DescribeReplicationInstances",
      "dms:ModifyReplicationInstance",
      "dms:CreateReplicationTask",
      "dms:DeleteReplicationTask",
      "dms:DescribeReplicationTasks",
      "dms:ModifyReplicationTask",
      "dms:StartReplicationTask",
      "dms:StopReplicationTask",
      "dms:CreateEndpoint",
      "dms:DeleteEndpoint",
      "dms:DescribeEndpoints",
      "dms:ModifyEndpoint",
      "dms:TestConnection",
      "dms:DescribeConnections",
      "dms:DescribeTableStatistics",
      "dms:DescribeReplicationTaskAssessmentResults"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DMSVPCAccess"
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute"
    ]
    resources = ["*"]
  }
}
