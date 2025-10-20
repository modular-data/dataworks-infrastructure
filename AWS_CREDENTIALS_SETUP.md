# AWS Credentials Setup

## Quick Setup

### Option 1: Source the credentials script before running commands

```bash
# Source the credentials
source ./scripts/setup-aws-credentials.sh

# Then run your commands
make bootstrap-dev
# or
./scripts/bootstrap-backend.sh dev
```

### Option 2: Export credentials manually

```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="eu-west-2"
export AWS_REGION="eu-west-2"
```

### Option 3: Use AWS CLI configure (persistent)

```bash
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY_ID
# AWS Secret Access Key: YOUR_SECRET_ACCESS_KEY
# Default region name: eu-west-2
# Default output format: json
```

## Credentials File

The file `scripts/setup-aws-credentials.sh` contains your actual credentials and is **git-ignored**.

**IMPORTANT**: This file is already configured with your credentials and is excluded from git.

## Testing Credentials

```bash
# Source credentials
source ./scripts/setup-aws-credentials.sh

# Test they work
aws sts get-caller-identity

# Should output something like:
# {
#     "UserId": "AIDAXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/username"
# }
```

## Usage Examples

### Bootstrap Backend

```bash
# Set up credentials first
source ./scripts/setup-aws-credentials.sh

# Bootstrap dev environment
make bootstrap-dev

# Or manually
./scripts/bootstrap-backend.sh dev
```

### Run Terraform

```bash
# Set up credentials first
source ./scripts/setup-aws-credentials.sh

# Initialize and plan
make plan-dev

# Apply
make apply-dev
```

## Security Notes

✅ **Good practices:**
- The actual credentials file (`setup-aws-credentials.sh`) is git-ignored
- Use environment variables (ephemeral)
- Credentials are only active in current shell session
- Close terminal when done to clear credentials

❌ **Bad practices:**
- Don't commit the credentials file
- Don't share the credentials script
- Don't hardcode credentials in Terraform files
- Don't store credentials in plain text files that aren't git-ignored

## Credential Rotation

When you need to rotate credentials:

1. Generate new access keys in AWS Console
2. Update `scripts/setup-aws-credentials.sh`
3. Test with `aws sts get-caller-identity`
4. Delete old access keys from AWS

## Troubleshooting

### "AccessDenied" errors
- Check credentials are correct
- Verify IAM user has necessary permissions
- Re-source the credentials script

### "InvalidAccessKeyId" errors
- Access key might be incorrect or deleted
- Check for typos in the credentials script

### Credentials not working
```bash
# Verify environment variables are set
echo $AWS_ACCESS_KEY_ID
echo $AWS_DEFAULT_REGION

# If empty, re-source the script
source ./scripts/setup-aws-credentials.sh
```

## Files Structure

```
scripts/
├── setup-aws-credentials.sh          ← YOUR ACTUAL CREDENTIALS (git-ignored)
├── setup-aws-credentials.sh.example  ← Template (can be committed)
└── bootstrap-backend.sh              ← Backend setup script
```

---

**Remember**: Always `source` the credentials script before running AWS commands!

```bash
source ./scripts/setup-aws-credentials.sh
```
