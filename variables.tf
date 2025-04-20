variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "data_bucket_name" {
  description = "Unique bucket for raw/output data"
  type        = string
  default     = "ga4-data-bucket-tf"
}

variable "script_bucket_name" {
  description = "Unique bucket for Glue scripts and credentials"
  type        = string
  default     = "ga4-script-bucket-tf"
}

variable "script_key" {
  description = "Key path in script bucket for the Glue job script"
  type        = string
  default     = "scripts/ga4_traffic_job.py"
}

variable "credentials_key" {
  description = "Key path in script bucket for the credentials JSON"
  type        = string
  default     = "bronze/traffic/config.json"
}

variable "database_name" {
  description = "Unique Glue DB name"
  type        = string
  default     = "ga4_traffic_db_tf"
}

variable "glue_job_name" {
  description = "Unique name for the Glue job"
  type        = string
  default     = "ga4-traffic-job-tf"
}
