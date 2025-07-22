.DEFAULT_GOAL := help

# Environment variables
ENV ?= dev
MODULES ?= iam-role glue-crawler glue-workflow glue-job-a glue-job-b glue-start-trigger glue-main-trigger

# Plan all modules
plan:  ## Run terragrunt plan for each module
	@for module in $(MODULES); do \
		echo "-> Planning $$module in $(ENV)..."; \
		cd deploy/envs/$(ENV)/$$module && \
		rm -rf .terragrunt-cache || true; \
		terragrunt init -reconfigure && \
		terragrunt plan || exit 1; \
		cd - > /dev/null; \
	done

# Apply all modules
deploy:  ## Run terragrunt apply for each module
	@for module in $(MODULES); do \
		echo "-> Applying $$module in $(ENV)..."; \
		cd deploy/envs/$(ENV)/$$module && \
		rm -rf .terragrunt-cache || true; \
		terragrunt init -reconfigure && \
		terragrunt apply -auto-approve || exit 1; \
		cd - > /dev/null; \
	done

# Show help
help:  ## Show available commands
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
