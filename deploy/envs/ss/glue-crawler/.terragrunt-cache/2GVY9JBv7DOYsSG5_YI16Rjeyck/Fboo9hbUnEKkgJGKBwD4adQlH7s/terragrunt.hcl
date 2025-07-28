include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/glue-crawler"
}

inputs = {
  name              = "titanic-crawler-raw-data"
  role              = "arn:aws:iam::165446266030:role/jenkins-glue-role"
  database_name     = "titanic_db"
  s3_target         = [                             # ✅ Correct key and format
    {
      path = "s3://vs-glue-test-job/sample-data/"
    }
  ]
  table_prefix      = "raw_"
  schedule          = "cron(0 12 * * ? *)"  # Optional
  configuration     = jsonencode({ "Version": 1.0 })
  glue_version      = "5.0"
  crawler_language  = "python"
}
