MAKEOPTS += --no-print-directory
.DEFAULT_GOAL := help

export ECR_URL
export APP_BUILD_NUMBER

export ENVIRONMENT := $(if $(ENV),$(ENV),dev)
export COMPOSE_FILE := ../docker-compose.ci.yml
export COMPOSE_PROJECT_NAME := legacy-data-pod

################################################################################
# LOCAL DEVELOPMENT ONLY
#
ifndef JENKINS_ENVIRONMENT
# Local environment setup
export CMD
export myBRANCH = $(shell git branch --show-current)
export BRANCH = $(if $(myBRANCH),$(myBRANCH),master)
export APP_BUILD_NUMBER = $(BRANCH)-$(shell git rev-parse --short HEAD)

AWS_AUTH_TARGETS := deploy publish _auth destroy output terragrunt
ifneq (,$(strip $(foreach goal,$(MAKECMDGOALS),$(findstring $(goal),$(AWS_AUTH_TARGETS)))))
export AWS_PROFILE := $(ENVIRONMENT)
export AWS_ACCOUNT_ID = $(shell aws sts get-caller-identity --query 'Account' --output text --profile $(AWS_PROFILE))
export ECR_ACCOUNT_ID = $(shell aws sts get-caller-identity --query 'Account' --output text --profile shared-services)
export ECR_DOMAIN = $(ECR_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com
export ECR_URL = $(ECR_DOMAIN)/
endif

_auth:
	@echo '--> Signing in to ECR: $(ECR_DOMAIN)'
	aws ecr get-login-password --region us-east-1 --profile shared-services | \
		docker login --username AWS --password-stdin $(ECR_DOMAIN)
.PHONY: _auth

publish: | _auth
endif
################################################################################

ifdef JENKINS_ENVIRONMENT
USERCREDS := $(if $(GIT_CREDS_USR),$(GIT_CREDS_USR):$(GIT_CREDS_PSW)@)
export TERRAGRUNT_SOURCE := git::https://$(USERCREDS)github.com$(shell sed -En 's| +source = "git::ssh://git@github.com(.+)"|\1|p' terragrunt.hcl)
endif

deploy:  ## Deploys the UDP glue stack
	@echo '--> Deploying $(APP_BUILD_NUMBER) to $(ENVIRONMENT)'
	@find deploy/envs/$(ENVIRONMENT) -mindepth 1 -maxdepth 1 -type d | while read dir; do \
		echo "\n==> Planning in $$dir"; \
		cd $$dir && rm -rf .terragrunt-cache && terragrunt plan -out legacy-data-pod.plan; \
		echo "\n==> Applying in $$dir"; \
		$(if $(DRYRUN),echo "--> WOULD RUN: ",terragrunt apply -auto-approve legacy-data-pod.plan); \
		cd - > /dev/null; \
	done

output:  ## Prints the outputs in terraform state for all modules
	@find deploy/envs/$(ENVIRONMENT) -mindepth 1 -maxdepth 1 -type d | while read dir; do \
		echo "\n==> Output for $$dir"; \
		cd $$dir && terragrunt output -json -no-color all || echo "⚠️ Failed to get output in $$dir"; \
		cd - > /dev/null; \
	done

terragrunt:  ## Runs a terragrunt command with ARGS in the deployment context
	terragrunt $(ARGS)

destroy:  ## Destroys all modules (dev only)
	@if [ "$(ENVIRONMENT)" != "dev" ]; then \
		echo "Refusing to destroy the environment in $(ENVIRONMENT)"; \
		exit 1; \
	fi
	@echo '--> Destroying modules in $(ENVIRONMENT)'
	@find deploy/envs/$(ENVIRONMENT) -mindepth 1 -maxdepth 1 -type d | while read dir; do \
		echo "\n==> Destroying $$dir"; \
		cd $$dir && rm -rf .terragrunt-cache && terragrunt destroy -auto-approve || echo "⚠️ Failed to destroy $$dir"; \
		cd - > /dev/null; \
	done

clean:  ## Removes compose artifacts
	docker-compose down --volumes --remove-orphans --rmi=local
	rm -rf ./.terragrunt-cache
.PHONY: stop

help: ## Display this help section
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-38s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
.PHONY: help
