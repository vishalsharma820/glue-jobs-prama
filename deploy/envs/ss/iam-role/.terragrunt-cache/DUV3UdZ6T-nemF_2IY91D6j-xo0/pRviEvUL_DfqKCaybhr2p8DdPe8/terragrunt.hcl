include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/iam-role"
}

inputs = {
  iam_role_name = "jenkins-glue-role"
  s3_bucket     = "vs-glue-test-job"
  region        = "us-east-1" # <-- Add this
}
