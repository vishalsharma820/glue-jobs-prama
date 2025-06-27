variable "region" {
  default = "us-east-1"
}

variable "s3_bucket" {
  default = "vs-glue-test-job"
}

variable "script_key" {
  default = "glue-scripts/myjob.py"
}
