# .DEFAULT_GOAL := help

# # Auto-detect module folders under envs/dev/ (not deploy/envs/dev/)
# MODULES := $(shell find envs/dev -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

# # Plan all modules in dev
# plan:  ## Run terragrunt plan for each module in dev
# 	@for module in $(MODULES); do \
# 		echo "-> Planning $$module in dev..."; \
# 		cd envs/dev/$$module && \
# 		rm -rf .terragrunt-cache || true; \
# 		terragrunt init -reconfigure && \
# 		terragrunt plan || exit 1; \
# 		cd - > /dev/null; \
# 	done

# # Show help
# help:  ## Show available commands
# 	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
.DEFAULT_GOAL := help

MODULE_DIR := deploy/envs/dev

plan:  ## Run terragrunt plan for a selected module or all
ifeq ($(MODULE_SELECTION), all)
	@for dir in $(shell find $(MODULE_DIR) -mindepth 1 -maxdepth 1 -type d); do \
		echo "-> Planning $$dir..."; \
		cd $$dir && \
		rm -rf .terragrunt-cache || true; \
		terragrunt init -reconfigure && \
		terragrunt plan || exit 1; \
		cd - > /dev/null; \
	done
else
	@echo "-> Planning $(MODULE_SELECTION)..."; \
	cd $(MODULE_DIR)/$(MODULE_SELECTION) && \
	rm -rf .terragrunt-cache || true; \
	terragrunt init -reconfigure && \
	terragrunt plan || exit 1; \
	cd - > /dev/null;
endif
