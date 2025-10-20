terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Backend configuration will be provided via -backend-config flag
    # bucket         = "dataworks-terraform-state-<env>"
    # key            = "project/dataworks-infrastructure"
    # region         = "eu-west-2"
    # dynamodb_table = "dataworks-terraform-state-<env>"
    # encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = local.all_tags
  }
}
