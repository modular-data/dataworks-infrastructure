#!/bin/bash

# Bootstrap script to create Terraform backend resources (S3 bucket and DynamoDB table)
# Usage: ./scripts/bootstrap-backend.sh <environment>
# Example: ./scripts/bootstrap-backend.sh dev

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ENVIRONMENT=$1
REGION=${AWS_DEFAULT_REGION:-eu-west-2}
PROJECT="dataworks"

export PATH=$PATH:/opt/homebrew/opt/libpq/bin:/Users/hari.chintala/.krew/bin:/Library/Java/JavaVirtualMachines/jdk1.8.0_361.jdk/Contents/Home/bin:/Users/hari.chintala/libs:/Library/Frameworks/Python.framework/Versions/3.11/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Applications/iTerm.app/Contents/Resources/utilities

if [ -z "$ENVIRONMENT" ]; then
    echo -e "${RED}Error: Environment not specified${NC}"
    echo "Usage: $0 <environment>"
    echo "Example: $0 dev"
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(development|test|prod)$ ]]; then
    echo -e "${RED}Error: Invalid environment. Must be development, test, or prod${NC}"
    exit 1
fi

BUCKET_NAME="${PROJECT}-terraform-state-${ENVIRONMENT}"
DYNAMODB_TABLE="${PROJECT}-terraform-state-${ENVIRONMENT}"

echo -e "${YELLOW}Starting bootstrap for environment: ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}Region: ${REGION}${NC}"
echo ""

# find aws CLI: prefer PATH, otherwise check common locations
AWS_CLI=""
if command -v aws >/dev/null 2>&1; then
    AWS_CLI="$(command -v aws)"
else
    # common install locations on macOS / Linux
    for p in /usr/local/bin/aws /opt/homebrew/bin/aws /usr/bin/aws /snap/bin/aws; do
        if [ -x "$p" ]; then
            AWS_CLI="$p"
            break
        fi
    done
fi

if [ -z "$AWS_CLI" ]; then
    echo -e "${RED}aws cli not found in PATH or common locations; please install or add to PATH${NC}"
    exit 1
fi

# Verify AWS account ID
echo -e "${YELLOW}Verifying AWS account...${NC}"
CURRENT_ACCOUNT=$("$AWS_CLI" sts get-caller-identity --query Account --output text 2>/dev/null)

if [ -z "$CURRENT_ACCOUNT" ]; then
    echo -e "${RED}Error: Unable to get AWS account ID. Check your credentials.${NC}"
    exit 1
fi

# Define expected account IDs per environment
case "$ENVIRONMENT" in
    development)
        EXPECTED_ACCOUNT="865517490483"
        ;;
    test)
        EXPECTED_ACCOUNT="TBD"  # Update when test account is known
        ;;
    prod)
        EXPECTED_ACCOUNT="TBD"  # Update when prod account is known
        ;;
esac

echo -e "Current AWS Account: ${CURRENT_ACCOUNT}"

if [ "$EXPECTED_ACCOUNT" != "TBD" ] && [ "$CURRENT_ACCOUNT" != "$EXPECTED_ACCOUNT" ]; then
    echo -e "${RED}Error: Account mismatch!${NC}"
    echo -e "${RED}Expected: ${EXPECTED_ACCOUNT} (${ENVIRONMENT})${NC}"
    echo -e "${RED}Current:  ${CURRENT_ACCOUNT}${NC}"
    echo -e "${YELLOW}Please update scripts/setup-aws-credentials.sh with credentials for account ${EXPECTED_ACCOUNT}${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Account verified: ${CURRENT_ACCOUNT}${NC}"
echo ""

# Check if bucket already exists
if "$AWS_CLI" s3 ls "s3://${BUCKET_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
    echo -e "${YELLOW}Creating S3 bucket: ${BUCKET_NAME}${NC}"

    # Create bucket
    if [ "$REGION" == "us-east-1" ]; then
        "$AWS_CLI" s3api create-bucket \
            --bucket "${BUCKET_NAME}" \
            --region "${REGION}"
    else
        "$AWS_CLI" s3api create-bucket \
            --bucket "${BUCKET_NAME}" \
            --region "${REGION}" \
            --create-bucket-configuration LocationConstraint="${REGION}"
    fi
    
    # Enable versioning
    echo -e "${YELLOW}Enabling versioning on S3 bucket${NC}"
    "$AWS_CLI" s3api put-bucket-versioning \
        --bucket "${BUCKET_NAME}" \
        --versioning-configuration Status=Enabled
    
    # Enable encryption
    echo -e "${YELLOW}Enabling encryption on S3 bucket${NC}"
    "$AWS_CLI" s3api put-bucket-encryption \
        --bucket "${BUCKET_NAME}" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }]
        }'
    
    # Block public access
    echo -e "${YELLOW}Blocking public access on S3 bucket${NC}"
    "$AWS_CLI" s3api put-public-access-block \
        --bucket "${BUCKET_NAME}" \
        --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    
    echo -e "${GREEN}✓ S3 bucket created successfully${NC}"
else
    echo -e "${GREEN}✓ S3 bucket already exists: ${BUCKET_NAME}${NC}"
fi

# Check if DynamoDB table already exists
if ! "$AWS_CLI" dynamodb describe-table --table-name "${DYNAMODB_TABLE}" --region "${REGION}" &>/dev/null; then
    echo -e "${YELLOW}Creating DynamoDB table: ${DYNAMODB_TABLE}${NC}"
    
    "$AWS_CLI" dynamodb create-table \
        --table-name "${DYNAMODB_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "${REGION}" \
        --tags Key=project,Value="${PROJECT}" \
               Key=environment,Value="${ENVIRONMENT}" \
               Key=terraform,Value=true \
               Key=purpose,Value="terraform-state-lock"
    
    echo -e "${YELLOW}Waiting for table to be active...${NC}"
    "$AWS_CLI" dynamodb wait table-exists --table-name "${DYNAMODB_TABLE}" --region "${REGION}"
    
    echo -e "${GREEN}✓ DynamoDB table created successfully${NC}"
else
    echo -e "${GREEN}✓ DynamoDB table already exists: ${DYNAMODB_TABLE}${NC}"
fi

echo ""
echo -e "${GREEN}Bootstrap complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Run terraform init with the following backend config:"
echo ""
echo "   terraform init \\"
echo "     -backend-config=\"bucket=${BUCKET_NAME}\" \\"
echo "     -backend-config=\"key=project/dataworks-infrastructure\" \\"
echo "     -backend-config=\"region=${REGION}\" \\"
echo "     -backend-config=\"dynamodb_table=${DYNAMODB_TABLE}\""
echo ""
echo "2. Run terraform plan:"
echo "   terraform plan -var-file=config/${ENVIRONMENT}.tfvars"
echo ""
echo "3. Run terraform apply:"
echo "   terraform apply -var-file=config/${ENVIRONMENT}.tfvars"
