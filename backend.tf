##########################
# Application Backend TF # 
##########################
# Note: The backend S3 bucket and DynamoDB table should be created manually
# or in a separate bootstrap process before running this Terraform.
# 
# The backend configuration is provided via -backend-config flags in the CircleCI pipeline.
# 
# To create the backend resources manually:
# 1. Create S3 bucket: dataworks-terraform-state-<env>
# 2. Create DynamoDB table: dataworks-terraform-state-<env> with hash key "LockID" (String)
#
# Example AWS CLI commands:
# aws s3api create-bucket --bucket dataworks-terraform-state-dev --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2
# aws dynamodb create-table --table-name dataworks-terraform-state-dev --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region eu-west-2
