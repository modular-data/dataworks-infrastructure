# USAGE GUIDE - Getting Started

## 🚀 Quick Start (Using Your Credentials)

### Step 1: Set Up AWS Credentials

Your AWS credentials are already configured in `scripts/setup-aws-credentials.sh` and git-ignored.

**Source the credentials before any AWS operation:**

```bash
source ./scripts/setup-aws-credentials.sh
```

You should see:
```
✓ AWS credentials configured
✓ Region: eu-west-2
✓ User: hari.chintala@isaggio.com
✓ AWS credentials are valid!
```

### Step 2: Bootstrap Backend (First Time Only)

```bash
# Make sure credentials are sourced first
source ./scripts/setup-aws-credentials.sh

# Bootstrap dev environment
make bootstrap-dev

# Bootstrap test and prod when ready
make bootstrap-test
make bootstrap-prod
```

### Step 3: Test Terraform Locally

```bash
# Make sure credentials are sourced first
source ./scripts/setup-aws-credentials.sh

# Plan for dev
make plan-dev

# If everything looks good, apply
make apply-dev
```

## 📋 Complete Workflow

### For Daily Development

```bash
# 1. Open terminal in project directory
cd /Users/hari.chintala/dataworks-infrastructure

# 2. Source AWS credentials
source ./scripts/setup-aws-credentials.sh

# 3. Make your changes to Terraform files
# Edit files...

# 4. Format code
make fmt

# 5. Plan changes
make plan-dev

# 6. Apply changes
make apply-dev
```

### For New Environment Setup

```bash
# Source credentials
source ./scripts/setup-aws-credentials.sh

# Bootstrap backend (creates S3 bucket and DynamoDB table)
make bootstrap-dev

# Initialize Terraform
make init-dev

# Plan infrastructure
make plan-dev

# Review plan output, then apply
make apply-dev
```

## 🔑 Your Credentials (Reference)

Your actual credentials are configured in `scripts/setup-aws-credentials.sh` (git-ignored).

**Note**: The credentials file is excluded from git for security. Never commit actual credentials to the repository.

```
Region: eu-west-2
```

## ⚡ Quick Commands

### Essential Commands (Always source credentials first!)

```bash
# Source credentials (DO THIS FIRST!)
source ./scripts/setup-aws-credentials.sh

# Bootstrap backend for environment
make bootstrap-dev      # or bootstrap-test or bootstrap-prod

# Terraform operations
make plan-dev          # Plan changes for dev
make apply-dev         # Apply changes to dev
make fmt               # Format Terraform files
make validate          # Validate configuration
make clean             # Clean up local files

# Test AWS access
aws sts get-caller-identity
aws s3 ls
```

## 📝 Typical Session Example

```bash
# Start of session
cd /Users/hari.chintala/dataworks-infrastructure
source ./scripts/setup-aws-credentials.sh

# First time setup - Bootstrap backend
make bootstrap-dev

# Work on infrastructure
make plan-dev
# Review output...
make apply-dev

# Make changes to s3.tf or other files
# ... edit files ...

# Apply changes
make plan-dev
make apply-dev

# End of session (credentials cleared when terminal closes)
```

## 🔒 Security Reminders

✅ **Your credentials file is git-ignored** - Safe!
- `scripts/setup-aws-credentials.sh` is in `.gitignore`
- It will never be committed to git
- You can safely keep it locally

❌ **Don't do this:**
- Don't commit the credentials file
- Don't share your credentials
- Don't email or message the credentials

## 🐛 Troubleshooting

### Problem: "AWS credentials not found"
**Solution:**
```bash
source ./scripts/setup-aws-credentials.sh
```

### Problem: "Access Denied" errors
**Solution:**
```bash
# Re-source credentials
source ./scripts/setup-aws-credentials.sh

# Verify they're set
echo $AWS_ACCESS_KEY_ID
echo $AWS_DEFAULT_REGION

# Test they work
aws sts get-caller-identity
```

### Problem: Commands don't find AWS credentials
**Solution:** Always source the script in the **same terminal** where you run commands:
```bash
# In terminal 1:
source ./scripts/setup-aws-credentials.sh
make bootstrap-dev  # ✅ Works - same terminal

# In terminal 2:
make bootstrap-dev  # ❌ Fails - credentials not sourced
```

### Problem: "bucket does not exist"
**Solution:** You need to bootstrap first:
```bash
source ./scripts/setup-aws-credentials.sh
make bootstrap-dev
```

### Problem: "aws: command not found" in VS Code but works in iTerm
**Cause:** VS Code's integrated terminal may not load the same shell rc or PATH as your iTerm session. The `aws` binary may live in `/usr/local/bin` or `/opt/homebrew/bin` which isn't on PATH inside VS Code.

**Fix:** Add the directory to your shell rc (e.g. `~/.zshrc`) or configure VS Code to include it:

1. Add to `~/.zshrc` (recommended):

```bash
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
```

2. Or configure VS Code (settings.json) to set the PATH for the integrated terminal:

```json
"terminal.integrated.env.osx": {
   "PATH": "/usr/local/bin:/opt/homebrew/bin:${env:PATH}"
}
```

After changing either, restart VS Code's terminal or the editor.

## 📂 What Gets Created

### After Bootstrap (per environment)
- S3 Bucket: `dataworks-terraform-state-<env>`
- DynamoDB Table: `dataworks-terraform-state-<env>`

### After Terraform Apply (per environment)
- 1 KMS Key for encryption
- 13 S3 Buckets for data storage
- All with proper encryption, tags, and lifecycle policies

## 🎯 Next Actions

1. **Now:** Source credentials
   ```bash
   source ./scripts/setup-aws-credentials.sh
   ```

2. **Bootstrap dev:**
   ```bash
   make bootstrap-dev
   ```

3. **Plan infrastructure:**
   ```bash
   make plan-dev
   ```

4. **Apply if looks good:**
   ```bash
   make apply-dev
   ```

---

**Remember**: Always source credentials first!
```bash
source ./scripts/setup-aws-credentials.sh
```

Then run any AWS or Terraform commands. ✨
