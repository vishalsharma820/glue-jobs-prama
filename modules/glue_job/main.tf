resource "aws_glue_job" "this" {
  name     = var.job_name
  role_arn = var.role_arn

  command {
    name            = "glueetl"
    script_location = var.script_location
    python_version  = "3"
  }

  glue_version      = var.glue_version
  number_of_workers = var.number_of_workers
  worker_type       = var.worker_type
  timeout           = var.timeout
  max_retries       = var.max_retries

  default_arguments = {
    "--TempDir"                          = var.temp_dir
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
  }
}
