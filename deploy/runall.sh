#!/bin/bash

set -e  # Exit on error

echo "🚀 Starting Glue Terraform deployment..."

declare -a MODULES=(
  "envs/dev/iam-role"
  "envs/dev/glue-workflow"
  "envs/dev/glue-job-a"
  "envs/dev/glue-job-b"
  "envs/dev/glue-trigger"
)

for module in "${MODULES[@]}"; do
  echo "📦 Applying module: $module"
  cd "$module"
  terragrunt apply -auto-approve
  cd - > /dev/null
done

echo "✅ All modules applied successfully!"
