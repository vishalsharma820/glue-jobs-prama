include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/glue-job"
}

locals {
  script_key         = "scripts/job_b.py"
  script_s3_path     = "s3://vs-glue-test-job/${local.script_key}"
  script_local_path  = abspath("${get_terragrunt_dir()}/../../../scripts/job_b.py")
}

inputs = {
  job_name           = "job-b-postprocess"
  role_arn           = "arn:aws:iam::165446266030:role/jenkins-glue-role"
  glue_version       = "5.0"
  worker_type        = "G.1X"
  number_of_workers  = 2

  script_location    = local.script_s3_path
  script_key         = local.script_key
  script_local_path  = local.script_local_path
  s3_bucket          = "vs-glue-test-job"
  temp_dir           = "s3://vs-glue-test-job/temp/"

  command = {
    name            = "glueetl"
    script_location = local.script_s3_path
    python_version  = 3
  }

  default_arguments = {
    "--INPUT_PATH"         = "s3://vs-glue-test-job/output/"
    "--FINAL_OUTPUT_PATH"  = "s3://vs-glue-test-job/final-output/"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--enable-metrics"      = "true"
  }
}
