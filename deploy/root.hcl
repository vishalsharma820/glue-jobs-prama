locals {
  region     = "us-east-1"
  s3_bucket  = "vs-glue-test-job"
  job_name   = basename(path_relative_to_include()) # Dynamically get job folder name
}

# remote_state {
#   backend = "s3"
#   config = {
#     bucket         = "glue-testjobjekins-state-bucket"
#     key            = "glue-job/${local.job_name}/terraform.tfstate" # Unique state key per job
#     region         = local.region
#     encrypt        = true
#     dynamodb_table = "terraform-lock-table"
#   }
# }
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "legacy-com-${local.environment}-terraform-state"
    key            = "deployment/glue/us-east-1/${local.environment}/${local.service_name}/terraform.tfstate"
    region         = local.region
    dynamodb_table = "terraform-locks" 
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
}
EOF
}
