# DataWorks Infrastructure

This repository contains the Terraform infrastructure code for the DataWorks project.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- CircleCI account with access to the repository

## Initial Setup

### 1. Bootstrap Terraform Backend

Before running Terraform for the first time, you need to create the backend resources (S3 bucket and DynamoDB table) for each environment.

Run the bootstrap script:

```bash
./scripts/bootstrap-backend.sh <environment>
```

Where `<environment>` is one of: `dev`, `test`, `prod`

Or manually create the resources:

```bash
# For dev environment
aws s3api create-bucket \
  --bucket dataworks-terraform-state-dev \
  --region eu-west-2 \
  --create-bucket-configuration LocationConstraint=eu-west-2

aws s3api put-bucket-versioning \
  --bucket dataworks-terraform-state-dev \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket dataworks-terraform-state-dev \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

aws dynamodb create-table \
  --table-name dataworks-terraform-state-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-west-2
```

Repeat for `test` and `prod` environments.

### 2. Configure CircleCI

1. Add the repository to CircleCI
2. Set up the following environment variables in CircleCI:
   - `AWS_ACCESS_KEY_ID` - AWS access key for deployment
   - `AWS_SECRET_ACCESS_KEY` - AWS secret access key for deployment
   - `AWS_DEFAULT_REGION` - Set to `eu-west-2`

3. Configure the CircleCI context `md-dataworks-common` with necessary permissions

## Infrastructure Components

### S3 Buckets

The following S3 buckets are created:

- **Glue Jobs Bucket**: Stores Glue job scripts and artifacts
- **Raw Archive Bucket**: Archive for raw data
- **Raw Zone Bucket**: Landing zone for raw data
- **Structured Zone Bucket**: Processed and structured data
- **Curated Zone Bucket**: Business-ready curated data
- **Temp Reload Bucket**: Temporary storage for reload operations
- **Domain Bucket**: Domain-specific data storage
- **Schema Registry Bucket**: Schema definitions and versions
- **Domain Config Bucket**: Domain configuration files
- **Violation Bucket**: Data validation violations
- **Landing Zone Bucket**: File transfer landing zone
- **Landing Processing Bucket**: Processing area for landed files
- **Quarantine Bucket**: Quarantined files

### Future Components (Commented Out)

- **Artifacts Store Bucket**: Application artifacts (requires Lambda function)
- **Working Bucket**: Working directory for jobs (requires additional configuration)

## Local Development

To run Terraform locally:

```bash
# Initialize Terraform
terraform init \
  -backend-config="bucket=dataworks-terraform-state-dev" \
  -backend-config="key=project/dataworks-infrastructure" \
  -backend-config="region=eu-west-2" \
  -backend-config="dynamodb_table=dataworks-terraform-state-dev"

# Plan changes
terraform plan -var-file=config/dev.tfvars

# Apply changes
terraform apply -var-file=config/dev.tfvars
```

## CircleCI Pipeline

The pipeline is configured to:

1. **Validate and Plan** - Runs on all branches
2. **Manual Approval** - Required for apply on main branch
3. **Apply** - Deploys infrastructure after approval

### Pipeline Flow

```
PR → Validate & Plan (dev)
  ↓
Merge to main → Validate & Plan (dev)
  ↓
Manual Approval (dev)
  ↓
Apply (dev)
  ↓
Validate & Plan (test)
  ↓
Manual Approval (test)
  ↓
Apply (test)
  ↓
Validate & Plan (prod)
  ↓
Manual Approval (prod)
  ↓
Apply (prod)
```

## Module Structure

```
.
├── .circleci/
│   └── config.yml          # CircleCI pipeline configuration
├── config/
│   ├── dev.tfvars          # Development environment variables
│   ├── test.tfvars         # Test environment variables
│   └── prod.tfvars         # Production environment variables
├── modules/
│   ├── s3_bucket/          # S3 bucket module
│   ├── secrets_manager/    # Secrets Manager module
│   ├── compute_node/       # EC2 compute node module
│   └── glue_database/      # Glue database module
├── backend.tf              # Terraform backend configuration
├── data.tf                 # Data sources
├── kms.tf                  # KMS key for S3 encryption
├── locals.tf               # Local variables
├── providers.tf            # Provider configuration
├── s3.tf                   # S3 bucket resources
├── variables.tf            # Input variables
└── README.md              # This file
```

## Environments

- **dev**: Development environment
- **test**: Testing environment
- **prod**: Production environment

## Tags

All resources are tagged with:

- `project`: dataworks
- `environment`: dev/test/prod
- `owner`: Team email
- `application`: dataworks-infrastructure
- `terraform`: true
- `business-unit`: data-platform

## Security

- All S3 buckets are encrypted using KMS
- Public access is blocked on all buckets
- State files are encrypted and versioned
- State locking is enabled via DynamoDB

## Contributing

1. Create a feature branch
2. Make your changes
3. Run `terraform fmt` to format code
4. Create a pull request
5. Wait for CI checks to pass
6. Get approval and merge

## Support

For issues or questions, contact: dataworks-team@digital.justice.gov.uk
