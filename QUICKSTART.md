# Quick Start Guide - DataWorks Infrastructure

## 🚀 Get Started in 5 Minutes

### Step 1: Bootstrap Backend (One-time setup)

```bash
# Bootstrap all environments
make bootstrap-dev
make bootstrap-test
make bootstrap-prod
```

Or manually for a specific environment:
```bash
./scripts/bootstrap-backend.sh dev
```

### Step 2: Test Locally

```bash
# Initialize and plan for dev
make plan-dev

# If everything looks good, apply
make apply-dev
```

### Step 3: Push to GitHub

```bash
# Create a feature branch
git checkout -b feature/initial-setup

# Add all files
git add .

# Commit
git commit -m "Initial infrastructure setup with CircleCI pipeline"

# Push
git push origin feature/initial-setup
```

### Step 4: Configure CircleCI

1. Go to CircleCI and add your repository
2. Add environment variables in CircleCI project settings:
   ```
   AWS_ACCESS_KEY_ID=<your-access-key>
   AWS_SECRET_ACCESS_KEY=<your-secret-key>
   AWS_DEFAULT_REGION=eu-west-2
   ```
3. Ensure the `md-dataworks-common` context exists with proper permissions

### Step 5: Create Pull Request

1. Create PR on GitHub
2. CircleCI will automatically run `terraform validate and plan` for dev
3. Review the plan output in CircleCI
4. Merge to main when ready

### Step 6: Deploy to Environments

After merging to main:

1. **Dev**: 
   - CircleCI runs plan automatically
   - Approve the `hold-dev` step
   - Apply runs automatically

2. **Test**:
   - After dev completes, test plan runs
   - Approve the `hold-test` step
   - Apply runs automatically

3. **Prod**:
   - After test completes, prod plan runs
   - Approve the `hold-prod` step
   - Apply runs automatically

## 📋 Common Commands

```bash
# Format all Terraform files
make fmt

# Validate configuration
make validate

# Initialize for specific environment
make init-dev
make init-test
make init-prod

# Plan for specific environment
make plan-dev
make plan-test
make plan-prod

# Apply for specific environment
make apply-dev
make apply-test
make apply-prod

# Clean up local Terraform files
make clean
```

## 🏗️ What Gets Created

### Backend Resources (per environment)
- S3 bucket: `dataworks-terraform-state-<env>`
- DynamoDB table: `dataworks-terraform-state-<env>`

### Infrastructure Resources (per environment)
- KMS key for S3 encryption
- 13 S3 buckets:
  - Glue jobs
  - Raw archive
  - Raw zone
  - Structured zone
  - Curated zone
  - Temp reload
  - Domain
  - Schema registry
  - Domain config
  - Violation
  - Landing zone
  - Landing processing
  - Quarantine

## 🔍 Checking Status

### Check backend exists:
```bash
# Check S3 bucket
aws s3 ls s3://dataworks-terraform-state-dev

# Check DynamoDB table
aws dynamodb describe-table --table-name dataworks-terraform-state-dev
```

### Check infrastructure:
```bash
# List all buckets
aws s3 ls | grep dataworks

# Get KMS key
aws kms list-keys
```

## 🐛 Troubleshooting

### Error: "bucket does not exist"
**Solution**: Run the bootstrap script first
```bash
make bootstrap-dev
```

### Error: "access denied"
**Solution**: Check AWS credentials
```bash
aws sts get-caller-identity
```

### Error: "CircleCI pipeline fails"
**Solution**: 
1. Check AWS credentials are set in CircleCI
2. Verify context `md-dataworks-common` exists
3. Check orb version is accessible

### Error: "state lock error"
**Solution**: Someone else is running terraform. Wait or force unlock:
```bash
terraform force-unlock <LOCK_ID>
```

## 📚 File Structure

```
dataworks-infrastructure/
├── .circleci/
│   └── config.yml           ← CircleCI pipeline
├── config/
│   ├── dev.tfvars          ← Dev variables
│   ├── test.tfvars         ← Test variables
│   └── prod.tfvars         ← Prod variables
├── modules/
│   └── s3_bucket/          ← S3 bucket module
├── scripts/
│   └── bootstrap-backend.sh ← Backend setup script
├── backend.tf               ← Backend configuration
├── data.tf                  ← Data sources
├── kms.tf                   ← KMS keys
├── locals.tf                ← Local variables
├── providers.tf             ← Provider config
├── s3.tf                    ← S3 buckets
├── variables.tf             ← Input variables
├── outputs.tf               ← Output values
├── Makefile                 ← Helper commands
└── README.md                ← Full documentation
```

## 🔐 Security Checklist

- ✅ State files encrypted in S3
- ✅ State locking enabled via DynamoDB
- ✅ All S3 buckets encrypted with KMS
- ✅ Public access blocked on all buckets
- ✅ IAM roles follow least privilege
- ✅ Separate state per environment
- ✅ No secrets in code

## 🎯 Next Steps

1. **Add more resources**: EC2, Glue, Secrets Manager
2. **Enable disabled buckets**: Artifacts store, Working bucket
3. **Add monitoring**: CloudWatch alarms, dashboards
4. **Add security scanning**: tfsec, checkov in pipeline
5. **Add cost estimation**: Infracost in pipeline

## 📞 Support

- Email: dataworks-team@digital.justice.gov.uk
- Docs: See README.md and SETUP_SUMMARY.md

---

**Happy Infrastructure Building! 🎉**
