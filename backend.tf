terraform {
  backend "s3" {
    bucket         = "glue-testjobjekins-state-bucket"   # replace with your bucket name
    key            = "glue-job/terraform.tfstate"    # path to your state file in S3
    region         = "us-east-1"                     # your region
    dynamodb_table = "terraform-lock-table"          # optional but recommended
    encrypt        = true
  }
}
