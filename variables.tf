variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket" {
  description = "S3 bucket for Glue script"
  type        = string
}

variable "script_key" {
  description = "S3 key for the Glue script"
  type        = string
}
