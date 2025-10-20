.PHONY: help init-dev init-test init-prod plan-dev plan-test plan-prod apply-dev apply-test apply-prod fmt validate clean bootstrap-dev bootstrap-test bootstrap-prod

# Default target
help:
	@echo "DataWorks Infrastructure - Makefile Commands"
	@echo "=============================================="
	@echo ""
	@echo "Bootstrap Commands (run these first):"
	@echo "  make bootstrap-dev     - Bootstrap backend for dev environment"
	@echo "  make bootstrap-test    - Bootstrap backend for test environment"
	@echo "  make bootstrap-prod    - Bootstrap backend for prod environment"
	@echo ""
	@echo "Initialization Commands:"
	@echo "  make init-dev          - Initialize Terraform for dev"
	@echo "  make init-test         - Initialize Terraform for test"
	@echo "  make init-prod         - Initialize Terraform for prod"
	@echo ""
	@echo "Plan Commands:"
	@echo "  make plan-dev          - Run terraform plan for dev"
	@echo "  make plan-test         - Run terraform plan for test"
	@echo "  make plan-prod         - Run terraform plan for prod"
	@echo ""
	@echo "Apply Commands:"
	@echo "  make apply-dev         - Run terraform apply for dev"
	@echo "  make apply-test        - Run terraform apply for test"
	@echo "  make apply-prod        - Run terraform apply for prod"
	@echo ""
	@echo "Utility Commands:"
	@echo "  make fmt               - Format all Terraform files"
	@echo "  make validate          - Validate Terraform configuration"
	@echo "  make clean             - Remove .terraform directory and lock file"
	@echo ""

# Bootstrap commands
bootstrap-dev:
	@echo "Bootstrapping backend for dev environment..."
	@./scripts/bootstrap-backend.sh dev

bootstrap-test:
	@echo "Bootstrapping backend for test environment..."
	@./scripts/bootstrap-backend.sh test

bootstrap-prod:
	@echo "Bootstrapping backend for prod environment..."
	@./scripts/bootstrap-backend.sh prod

# Initialization commands
init-dev:
	@echo "Initializing Terraform for dev environment..."
	terraform init \
		-backend-config="bucket=dataworks-terraform-state-dev" \
		-backend-config="key=project/dataworks-infrastructure" \
		-backend-config="region=eu-west-2" \
		-backend-config="dynamodb_table=dataworks-terraform-state-dev"

init-test:
	@echo "Initializing Terraform for test environment..."
	terraform init \
		-backend-config="bucket=dataworks-terraform-state-test" \
		-backend-config="key=project/dataworks-infrastructure" \
		-backend-config="region=eu-west-2" \
		-backend-config="dynamodb_table=dataworks-terraform-state-test"

init-prod:
	@echo "Initializing Terraform for prod environment..."
	terraform init \
		-backend-config="bucket=dataworks-terraform-state-prod" \
		-backend-config="key=project/dataworks-infrastructure" \
		-backend-config="region=eu-west-2" \
		-backend-config="dynamodb_table=dataworks-terraform-state-prod"

# Plan commands
plan-dev: init-dev
	@echo "Running terraform plan for dev..."
	terraform plan -var-file=config/dev.tfvars

plan-test: init-test
	@echo "Running terraform plan for test..."
	terraform plan -var-file=config/test.tfvars

plan-prod: init-prod
	@echo "Running terraform plan for prod..."
	terraform plan -var-file=config/prod.tfvars

# Apply commands
apply-dev: init-dev
	@echo "Running terraform apply for dev..."
	terraform apply -var-file=config/dev.tfvars

apply-test: init-test
	@echo "Running terraform apply for test..."
	terraform apply -var-file=config/test.tfvars

apply-prod: init-prod
	@echo "Running terraform apply for prod..."
	terraform apply -var-file=config/prod.tfvars

# Utility commands
fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

validate:
	@echo "Validating Terraform configuration..."
	terraform validate

clean:
	@echo "Cleaning up Terraform files..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	@echo "Clean complete!"

# Combined commands
dev-full: bootstrap-dev init-dev plan-dev
	@echo "Dev environment ready. Run 'make apply-dev' to apply changes."

test-full: bootstrap-test init-test plan-test
	@echo "Test environment ready. Run 'make apply-test' to apply changes."

prod-full: bootstrap-prod init-prod plan-prod
	@echo "Prod environment ready. Run 'make apply-prod' to apply changes."
