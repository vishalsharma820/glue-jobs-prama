.DEFAULT_GOAL := help

# Auto-detect module folders under envs/dev/ (not deploy/envs/dev/)
MODULES := $(shell find envs/dev -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

# Plan all modules in dev
plan:  ## Run terragrunt plan for each module in dev
	@for module in $(MODULES); do \
		echo "-> Planning $$module in dev..."; \
		cd envs/dev/$$module && \
		rm -rf .terragrunt-cache || true; \
		terragrunt init -reconfigure && \
		terragrunt plan || exit 1; \
		cd - > /dev/null; \
	done

# Show help
help:  ## Show available commands
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
