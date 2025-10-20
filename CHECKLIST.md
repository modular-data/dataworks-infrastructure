# DataWorks Infrastructure - Setup Checklist

## Pre-Deployment Checklist

### ☐ 1. AWS Prerequisites
- [ ] AWS CLI installed and configured
- [ ] AWS credentials have appropriate permissions:
  - [ ] S3 full access (for state bucket)
  - [ ] DynamoDB full access (for state locking)
  - [ ] KMS key management
  - [ ] EC2/VPC permissions (for future resources)
- [ ] Access to AWS account for dev environment
- [ ] Access to AWS account for test environment
- [ ] Access to AWS account for prod environment

### ☐ 2. Local Environment Setup
- [ ] Terraform installed (version >= 1.0)
- [ ] Git installed
- [ ] Make installed (optional, for using Makefile)
- [ ] Repository cloned locally
- [ ] Scripts have execute permissions (`chmod +x scripts/*.sh`)

### ☐ 3. Backend Bootstrap (Critical - Do First!)
- [ ] Run bootstrap for dev: `make bootstrap-dev`
- [ ] Verify dev S3 bucket created: `aws s3 ls s3://dataworks-terraform-state-dev`
- [ ] Verify dev DynamoDB table created: `aws dynamodb describe-table --table-name dataworks-terraform-state-dev`
- [ ] Run bootstrap for test: `make bootstrap-test`
- [ ] Verify test backend resources
- [ ] Run bootstrap for prod: `make bootstrap-prod`
- [ ] Verify prod backend resources

### ☐ 4. Local Testing
- [ ] Run `terraform fmt` to format code
- [ ] Run `make validate` to validate configuration
- [ ] Run `make plan-dev` to see plan output
- [ ] Review plan output for any errors
- [ ] Fix any issues found

### ☐ 5. CircleCI Setup
- [ ] Repository added to CircleCI
- [ ] CircleCI context `md-dataworks-common` created
- [ ] Environment variables configured in CircleCI:
  - [ ] `AWS_ACCESS_KEY_ID`
  - [ ] `AWS_SECRET_ACCESS_KEY`
  - [ ] `AWS_DEFAULT_REGION` (set to `eu-west-2`)
- [ ] Test pipeline runs successfully on a feature branch

### ☐ 6. Git Repository
- [ ] All files committed
- [ ] .gitignore properly configured
- [ ] Sensitive files not committed (check with `git status`)
- [ ] Feature branch created
- [ ] Changes pushed to GitHub

### ☐ 7. First Deployment - Dev
- [ ] Pull request created
- [ ] CircleCI validates and plans successfully
- [ ] Plan output reviewed
- [ ] PR approved and merged to main
- [ ] CircleCI plan runs on main branch
- [ ] Manual approval given for dev deployment
- [ ] Dev apply completes successfully
- [ ] Verify resources in AWS console:
  - [ ] KMS key created
  - [ ] All S3 buckets created
  - [ ] Tags are correct

### ☐ 8. Test Environment Deployment
- [ ] Test plan runs automatically after dev
- [ ] Review test plan output
- [ ] Manual approval given for test deployment
- [ ] Test apply completes successfully
- [ ] Verify test resources in AWS

### ☐ 9. Production Deployment
- [ ] Prod plan runs automatically after test
- [ ] Review prod plan output carefully
- [ ] Get sign-off from team lead
- [ ] Manual approval given for prod deployment
- [ ] Prod apply completes successfully
- [ ] Verify prod resources in AWS

### ☐ 10. Post-Deployment Verification
- [ ] All buckets accessible
- [ ] KMS encryption working
- [ ] Bucket policies correct
- [ ] Tags applied correctly
- [ ] Outputs captured
- [ ] Documentation updated

## Common Issues Checklist

### Issue: Backend Initialization Fails
- [ ] Backend resources created? Run bootstrap script
- [ ] Correct AWS credentials?
- [ ] Correct region specified?
- [ ] Bucket name matches in backend config?
- [ ] DynamoDB table name matches?

### Issue: Plan Shows Unexpected Changes
- [ ] Correct tfvars file being used?
- [ ] State file in sync?
- [ ] Manual changes made in AWS console?
- [ ] Module versions changed?

### Issue: CircleCI Pipeline Fails
- [ ] AWS credentials configured in CircleCI?
- [ ] Context properly configured?
- [ ] Orb version accessible?
- [ ] Backend resources exist?
- [ ] Branch name correct?

### Issue: Apply Fails
- [ ] Plan reviewed before apply?
- [ ] AWS permissions sufficient?
- [ ] Resources already exist?
- [ ] Name conflicts?
- [ ] Quota limits reached?

## Rollback Checklist

### If Something Goes Wrong
- [ ] Stop any running applies
- [ ] Identify what changed
- [ ] Check state file for corruption
- [ ] Review Terraform state: `terraform state list`
- [ ] If needed, import existing resources
- [ ] If critical, revert to last known good state
- [ ] Document the issue
- [ ] Fix and re-test in dev first

## Maintenance Checklist (Weekly)

- [ ] Check for Terraform updates
- [ ] Check for AWS provider updates
- [ ] Check for security vulnerabilities
- [ ] Review AWS costs
- [ ] Check state file backups exist
- [ ] Review and clean up old resources
- [ ] Update documentation if needed

## Maintenance Checklist (Monthly)

- [ ] Review access logs
- [ ] Audit IAM permissions
- [ ] Check for drift: `terraform plan` on all environments
- [ ] Review and update lifecycle policies
- [ ] Test disaster recovery procedures
- [ ] Review and optimize costs
- [ ] Update team documentation

## Documentation Checklist

- [ ] README.md is up to date
- [ ] SETUP_SUMMARY.md reflects current state
- [ ] QUICKSTART.md is accurate
- [ ] Architecture diagrams updated
- [ ] Runbooks created for common tasks
- [ ] Incident response procedures documented

## Team Onboarding Checklist

For new team members:
- [ ] Access to GitHub repository
- [ ] Access to CircleCI
- [ ] AWS console access
- [ ] AWS CLI configured
- [ ] Read README.md
- [ ] Read QUICKSTART.md
- [ ] Clone repository
- [ ] Run `make plan-dev` successfully
- [ ] Shadow a deployment
- [ ] Complete first deployment with supervision

## Security Audit Checklist

- [ ] All buckets have encryption enabled
- [ ] Public access blocked on all buckets
- [ ] State files encrypted
- [ ] No secrets in code
- [ ] IAM roles follow least privilege
- [ ] KMS key rotation enabled
- [ ] Logging enabled where required
- [ ] Tags include owner and environment
- [ ] Access logs reviewed regularly

## Completion Sign-off

### Dev Environment
- Deployed by: ________________
- Date: ________________
- Verified by: ________________
- Notes: ________________

### Test Environment
- Deployed by: ________________
- Date: ________________
- Verified by: ________________
- Notes: ________________

### Production Environment
- Deployed by: ________________
- Date: ________________
- Verified by: ________________
- Notes: ________________

---

**Keep this checklist updated as the infrastructure evolves!**

Last Updated: October 20, 2025
