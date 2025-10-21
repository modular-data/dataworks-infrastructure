resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name               = var.role_name
  assume_role_policy = var.assume_role_policy
  description        = var.description
  tags               = var.tags

  max_session_duration = var.max_session_duration
}

# Attach managed policies
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = var.create_role ? toset(var.managed_policy_arns) : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

# Attach custom policies based on type
resource "aws_iam_role_policy" "s3_read_kms_read" {
  count = var.create_role && var.attach_s3_read_kms_read_policy ? 1 : 0

  name   = "${var.role_name}-s3-read-kms-read"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.s3_read_kms_read[0].json
}

resource "aws_iam_role_policy" "s3_readwrite_kms" {
  count = var.create_role && var.attach_s3_readwrite_kms_policy ? 1 : 0

  name   = "${var.role_name}-s3-readwrite-kms"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.s3_readwrite_kms[0].json
}

resource "aws_iam_role_policy" "glue_readwrite" {
  count = var.create_role && var.attach_glue_readwrite_policy ? 1 : 0

  name   = "${var.role_name}-glue-readwrite"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.glue_readwrite[0].json
}

resource "aws_iam_role_policy" "lambda_readwrite" {
  count = var.create_role && var.attach_lambda_readwrite_policy ? 1 : 0

  name   = "${var.role_name}-lambda-readwrite"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.lambda_readwrite[0].json
}

resource "aws_iam_role_policy" "dms_readwrite" {
  count = var.create_role && var.attach_dms_readwrite_policy ? 1 : 0

  name   = "${var.role_name}-dms-readwrite"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.dms_readwrite[0].json
}

# Custom inline policies
resource "aws_iam_role_policy" "custom" {
  for_each = var.create_role ? var.custom_inline_policies : {}

  name   = each.key
  role   = aws_iam_role.this[0].id
  policy = each.value
}
