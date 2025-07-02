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
  # Use abspath to resolve the actual file path
  script_local_path = abspath("${get_terragrunt_dir()}/../../../scripts/myjob.py")
}

inputs = {
  job_name          = "glue-job-a"
  role_arn          = "arn:aws:iam::165446266030:role/jenkins-glue-role"
  script_location   = "s3://vs-glue-test-job/scripts/myjob.py"  # This is still needed by Glue
  script_key        = "scripts/myjob.py"                        # 👈 New input for S3 upload
  s3_bucket         = "vs-glue-test-job"                        # 👈 New input for S3 upload
  script_local_path  = local.script_local_path
  number_of_workers = 2
  worker_type       = "G.1X"
  glue_version      = "5.0"
  timeout           = 10
  max_retries       = 1
  temp_dir          = "s3://vs-glue-test-job/temp/"
}
