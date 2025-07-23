.DEFAULT_GOAL := help

# Plan all folders under deploy/envs/dev
plan: ## Run terragrunt plan for all modules under dev
	@for dir in $(shell find envs/dev -maxdepth 1 -mindepth 1 -type d); do \
		echo "-> Planning $${dir}..."; \
		cd $$dir && \
		rm -rf .terragrunt-cache || true; \
		terragrunt init -reconfigure && \
		terragrunt plan || exit 1; \
		cd - > /dev/null; \
	done

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
