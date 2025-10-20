#!/bin/bash

# Verification script to check setup before running bootstrap
# Usage: ./scripts/verify-setup.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================"
echo "   DataWorks Infrastructure Setup      "
echo "         Verification Script           "
echo "========================================"
echo ""

ERRORS=0
WARNINGS=0

# Check 1: AWS CLI installed (also check common locations)
echo -n "Checking AWS CLI... "
AWS_CLI=""
if command -v aws &> /dev/null; then
    AWS_CLI="$(command -v aws)"
else
    for p in /usr/local/bin/aws /opt/homebrew/bin/aws /usr/bin/aws /snap/bin/aws; do
        if [ -x "$p" ]; then
            AWS_CLI="$p"
            break
        fi
    done
fi

if [ -n "$AWS_CLI" ]; then
    AWS_VERSION=$($AWS_CLI --version 2>&1)
    echo -e "${GREEN}✓ Found${NC} ($AWS_CLI) - $AWS_VERSION"
else
    echo -e "${RED}✗ Not found${NC}"
    echo "  Install: https://aws.amazon.com/cli/"
    echo "  If aws works in iTerm but not VS Code/this shell, add the location (e.g. /usr/local/bin or /opt/homebrew/bin) to your PATH in your shell rc (~/.zshrc) or configure VS Code's terminal.integrated.env.osx to include it."
    ((ERRORS++))
fi

# Check 2: Terraform installed
echo -n "Checking Terraform... "
if command -v terraform &> /dev/null; then
    TF_VERSION=$(terraform version -json 2>/dev/null | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
    echo -e "${GREEN}✓ Installed${NC} (v$TF_VERSION)"
else
    echo -e "${RED}✗ Not found${NC}"
    echo "  Install: https://www.terraform.io/downloads"
    ((ERRORS++))
fi

# Check 3: AWS Credentials configured
echo -n "Checking AWS credentials... "
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
    echo -e "${GREEN}✓ Configured${NC}"
    echo "  Access Key: ${AWS_ACCESS_KEY_ID:0:10}..."
    echo "  Region: $AWS_DEFAULT_REGION"
else
    echo -e "${YELLOW}⚠ Not set${NC}"
    echo "  Run: source ./scripts/setup-aws-credentials.sh"
    ((WARNINGS++))
fi

# Check 4: AWS credentials valid
if [ -n "$AWS_ACCESS_KEY_ID" ]; then
    echo -n "Verifying AWS credentials... "
    if CALLER_ID=$($AWS_CLI sts get-caller-identity 2>/dev/null); then
        ACCOUNT=$(echo $CALLER_ID | grep -o '"Account":"[^"]*' | cut -d'"' -f4)
        USER=$(echo $CALLER_ID | grep -o '"Arn":"[^"]*' | cut -d'"' -f4)
        echo -e "${GREEN}✓ Valid${NC}"
        echo "  Account: $ACCOUNT"
        echo "  User: $USER"
        
        # Check if account matches dev account
        if [ "$ACCOUNT" = "865517490483" ]; then
            echo -e "  ${GREEN}✓ Matches dev account${NC}"
        else
            echo -e "  ${YELLOW}⚠ Different account (expected: 865517490483)${NC}"
        fi
    else
        echo -e "${RED}✗ Invalid or expired${NC}"
        ((ERRORS++))
    fi
fi

# Check 5: Required files exist
echo -n "Checking required files... "
REQUIRED_FILES=(
    "backend.tf"
    "providers.tf"
    "variables.tf"
    "locals.tf"
    "s3.tf"
    "kms.tf"
    "config/dev.tfvars"
    "scripts/bootstrap-backend.sh"
    "Makefile"
)

MISSING_FILES=0
for FILE in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$FILE" ]; then
        if [ $MISSING_FILES -eq 0 ]; then
            echo ""
        fi
        echo -e "  ${RED}✗ Missing: $FILE${NC}"
        ((MISSING_FILES++))
        ((ERRORS++))
    fi
done

if [ $MISSING_FILES -eq 0 ]; then
    echo -e "${GREEN}✓ All present${NC}"
fi

# Check 6: Scripts are executable
echo -n "Checking script permissions... "
    if [ -x "scripts/bootstrap-backend.sh" ] && [ -x "scripts/setup-aws-credentials.sh" ]; then
    echo -e "${GREEN}✓ Executable${NC}"
else
    echo -e "${YELLOW}⚠ Not executable${NC}"
    echo "  Run: chmod +x scripts/*.sh"
    ((WARNINGS++))
fi

# Check 7: Git repository initialized
echo -n "Checking git repository... "
if [ -d ".git" ]; then
    echo -e "${GREEN}✓ Initialized${NC}"
else
    echo -e "${YELLOW}⚠ Not initialized${NC}"
    echo "  Run: git init"
    ((WARNINGS++))
fi

# Check 8: Credentials file is git-ignored
if [ -d ".git" ]; then
    echo -n "Checking credentials are git-ignored... "
    if git check-ignore -q scripts/setup-aws-credentials.sh; then
        echo -e "${GREEN}✓ Ignored${NC}"
    else
        echo -e "${RED}✗ NOT IGNORED - SECURITY RISK!${NC}"
        echo "  The credentials file is NOT in .gitignore"
        ((ERRORS++))
    fi
fi

# Check 9: Config files valid
echo -n "Checking dev config... "
if grep -q "865517490483" config/dev.tfvars 2>/dev/null; then
    echo -e "${GREEN}✓ Account ID configured${NC}"
else
    echo -e "${YELLOW}⚠ Account ID not found${NC}"
    ((WARNINGS++))
fi

echo ""
echo "========================================"
echo "           Summary                      "
echo "========================================"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "You're ready to bootstrap:"
    echo "  source ./scripts/setup-aws-credentials.sh"
    echo "  make bootstrap-dev"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    echo ""
    echo "You can proceed, but review the warnings above."
    echo ""
    echo "Next steps:"
    echo "  source ./scripts/setup-aws-credentials.sh"
    echo "  make bootstrap-dev"
    exit 0
else
    echo -e "${RED}✗ $ERRORS error(s) found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    fi
    echo ""
    echo "Please fix the errors above before proceeding."
    exit 1
fi
