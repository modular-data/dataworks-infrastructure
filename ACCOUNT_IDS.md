# AWS Account IDs - Reference

This file documents the AWS Account IDs for each environment.

## Account IDs

### Development
- **Account ID**: `865517490483`
- **Region**: `eu-west-2`
- **Owner**: hari.chintala@isaggio.com
- **Purpose**: Development and testing

### Test
- **Account ID**: TBD (To Be Determined)
- **Region**: `eu-west-2`
- **Owner**: hari.chintala@isaggio.com
- **Purpose**: Pre-production testing

### Production
- **Account ID**: TBD (To Be Determined)
- **Region**: `eu-west-2`
- **Owner**: hari.chintala@isaggio.com
- **Purpose**: Production workloads

## Usage

The account IDs are configured in the respective tfvars files:
- `config/dev.tfvars` - Contains dev account ID (865517490483)
- `config/test.tfvars` - Update when test account is available
- `config/prod.tfvars` - Update when prod account is available

## Verification

To verify you're using the correct account:

```bash
# Source credentials
source ./scripts/setup-aws-credentials.sh

# Check current account
aws sts get-caller-identity

# Should show:
# "Account": "865517490483"
```

## Backend Resources

Each account has its own backend resources:

### Dev Account (865517490483)
- S3 Bucket: `dataworks-terraform-state-dev`
- DynamoDB Table: `dataworks-terraform-state-dev`
- Region: `eu-west-2`

### Test Account (TBD)
- S3 Bucket: `dataworks-terraform-state-test`
- DynamoDB Table: `dataworks-terraform-state-test`
- Region: `eu-west-2`

### Prod Account (TBD)
- S3 Bucket: `dataworks-terraform-state-prod`
- DynamoDB Table: `dataworks-terraform-state-prod`
- Region: `eu-west-2`

## Multi-Account Setup

If using different AWS accounts for different environments, you'll need:

1. Separate AWS credentials for each account
2. Multiple credential scripts or AWS profiles
3. Update the credentials script when switching environments

### Example Multi-Account Setup

```bash
# Option 1: Use AWS profiles
aws configure --profile dataworks-dev
aws configure --profile dataworks-test
aws configure --profile dataworks-prod

# Then specify profile when running commands
export AWS_PROFILE=dataworks-dev
make bootstrap-dev

# Option 2: Create separate credential scripts
source ./scripts/setup-aws-credentials-dev.sh
source ./scripts/setup-aws-credentials-test.sh
source ./scripts/setup-aws-credentials-prod.sh
```

## Security Notes

- Account IDs are not sensitive and can be committed to git
- Credentials (access keys) should NEVER be committed
- Each environment should have separate IAM users/roles
- Use principle of least privilege for each account

## Update History

- 2025-10-20: Dev account configured (865517490483)
- TBD: Test account to be added
- TBD: Prod account to be added
