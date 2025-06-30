variable "job_name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "script_location" {
  type = string
}

variable "number_of_workers" {
  type = number
}

variable "worker_type" {
  type = string
}

variable "glue_version" {
  type    = string
  default = "5.0"
}

variable "timeout" {
  type    = number
  default = 10
}

variable "max_retries" {
  type    = number
  default = 1
}

variable "temp_dir" {
  type = string
}
