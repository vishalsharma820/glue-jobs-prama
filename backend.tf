terraform {
  backend "s3" {
    bucket         = "my-glue-etl-tf-state"
    key            = "etl/terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "glue-terraform-locks"
    # encrypt        = true
  }
}
