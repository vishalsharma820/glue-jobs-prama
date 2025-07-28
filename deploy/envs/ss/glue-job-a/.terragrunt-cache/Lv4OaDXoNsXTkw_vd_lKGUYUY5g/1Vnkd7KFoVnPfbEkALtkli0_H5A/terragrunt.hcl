include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/glue-job"
}

locals {
  script_local_path = abspath("${get_terragrunt_dir()}/../../../scripts/job_a.py")
}

inputs = {
  job_name             = "titanic-data-transform"
  role_arn             = "arn:aws:iam::165446266030:role/jenkins-glue-role"
  glue_version         = "4.0"
  number_of_workers    = 2
  worker_type          = "G.1X"

  script_local_path    = local.script_local_path
  script_location      = "s3://vs-glue-test-job/scripts/job_a.py"
  script_key           = "scripts/job_a.py"
  s3_bucket            = "vs-glue-test-job"
  temp_dir             = "s3://vs-glue-test-job/temp/"

  default_arguments = {
    "--SOURCE_DATABASE"     = "titanic_db"
    "--SOURCE_TABLE"        = "raw_sample_data"
    "--OUTPUT_PATH"         = "s3://vs-glue-test-job/output/"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--enable-metrics"      = "true"
  }

  command = {
    name            = "glueetl"
    script_location = "s3://vs-glue-test-job/scripts/job_a.py"
    python_version  = 3
  }
}
