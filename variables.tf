variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod)"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
  default     = ""
}

variable "setup_buckets" {
  type        = bool
  description = "Whether to create S3 buckets"
  default     = true
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "dataworks"
}

variable "business_unit" {
  type        = string
  description = "Business unit name"
  default     = "data-platform"
}

variable "owner" {
  type        = string
  description = "Owner email"
  default     = "hari.chintala@isaggio.com"
}

variable "application" {
  type        = string
  description = "Application name"
  default     = "dataworks-infrastructure"
}
