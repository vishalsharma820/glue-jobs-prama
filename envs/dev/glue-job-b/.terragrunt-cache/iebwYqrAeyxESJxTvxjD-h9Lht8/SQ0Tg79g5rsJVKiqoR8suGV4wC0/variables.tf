variable "job_name" {
  description = "Name of the Glue job"
  type        = string
}

variable "role_arn" {
  description = "IAM role ARN for the Glue job"
  type        = string
}

variable "script_location" {
  description = "S3 URI for the Glue job script"
  type        = string
}

variable "script_key" {
  description = "S3 key path for the Glue script"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket to store Glue script"
  type        = string
}

variable "number_of_workers" {
  description = "Number of workers to run the Glue job"
  type        = number
}

variable "worker_type" {
  description = "Type of worker (Standard, G.1X, G.2X, etc.)"
  type        = string
}

variable "glue_version" {
  description = "Glue version to use"
  type        = string
  default     = "5.0"
}

variable "timeout" {
  description = "Job timeout in minutes"
  type        = number
  default     = 10
}

variable "max_retries" {
  description = "Maximum number of retry attempts"
  type        = number
  default     = 1
}

variable "temp_dir" {
  description = "S3 path for temporary directory"
  type        = string
}

variable "script_local_path" {
  description = "Absolute local path to the Glue script for upload"
  type        = string
}
