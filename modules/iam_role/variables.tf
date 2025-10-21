variable "create_role" {
  description = "Whether to create the IAM role"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "JSON string of the assume role policy document"
  type        = string
}

variable "description" {
  description = "Description of the IAM role"
  type        = string
  default     = ""
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds"
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Tags to apply to the role"
  type        = map(string)
  default     = {}
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "custom_inline_policies" {
  description = "Map of custom inline policies to attach (name => policy json)"
  type        = map(string)
  default     = {}
}

# Policy toggles
variable "attach_s3_read_kms_read_policy" {
  description = "Attach S3 read + KMS read only policy"
  type        = bool
  default     = false
}

variable "attach_s3_readwrite_kms_policy" {
  description = "Attach S3 read/write + KMS policy"
  type        = bool
  default     = false
}

variable "attach_glue_readwrite_policy" {
  description = "Attach Glue read/write policy"
  type        = bool
  default     = false
}

variable "attach_lambda_readwrite_policy" {
  description = "Attach Lambda read/write policy"
  type        = bool
  default     = false
}

variable "attach_dms_readwrite_policy" {
  description = "Attach DMS read/write policy"
  type        = bool
  default     = false
}

# Resource ARNs for policies
variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs for policies (include both bucket and bucket/* for objects)"
  type        = list(string)
  default     = ["*"]
}

variable "kms_key_arns" {
  description = "List of KMS key ARNs for policies"
  type        = list(string)
  default     = ["*"]
}
