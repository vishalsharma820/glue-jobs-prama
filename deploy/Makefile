.DEFAULT_GOAL := help

# Plan all modules in deploy/envs/dev
plan: ## Run terragrunt plan for each module in dev
	@for dir in $(shell find envs/dev -maxdepth 1 -mindepth 1 -type d); do \
		echo "-> Planning in $$dir..."; \
		cd $$dir && \
		rm -rf .terragrunt-cache || true; \
		terragrunt init -reconfigure && \
		terragrunt plan || exit 1; \
		cd - > /dev/null; \
	done

# Apply all modules in deploy/envs/dev
deploy: ## Run terragrunt apply for each module in dev
	@for dir in $(shell find envs/dev -maxdepth 1 -mindepth 1 -type d); do \
		echo "-> Applying in $$dir..."; \
		cd $$dir && \
		rm -rf .terragrunt-cache || true; \
		terragrunt init -reconfigure && \
		terragrunt apply -auto-approve || exit 1; \
		cd - > /dev/null; \
	done

# Show help
help: ## Show available commands
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
