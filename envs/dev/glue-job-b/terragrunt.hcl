include {
  path = find_in_parent_folders("root.hcl")
}

dependency "iam_role" {
  config_path = "../iam-role"
}

terraform {
  source = "../../../modules/glue_job"
}

locals {
  # Use abspath to resolve the path to mysecondjob.py
  script_local_path = abspath("${get_terragrunt_dir()}/../../../scripts/mysecondjob.py")
}

inputs = {
  job_name           = "glue-job-b"
  role_arn           = dependency.iam_role.outputs.role_arn
  script_location    = "s3://vs-glue-test-job/scripts/mysecondjob.py"
  script_key         = "scripts/mysecondjob.py"
  script_local_path  = local.script_local_path
  s3_bucket          = "vs-glue-test-job"
  number_of_workers  = 3
  worker_type        = "G.2X"
  glue_version       = "5.0"
  timeout            = 15
  max_retries        = 2
  temp_dir           = "s3://vs-glue-test-job/temp/"
}
