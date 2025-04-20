output "data_bucket" {
  value = aws_s3_bucket.ga4_data_bucket.bucket
}

output "script_bucket" {
  value = aws_s3_bucket.ga4_script_bucket.bucket
}

output "glue_job" {
  value = aws_glue_job.ga4_traffic_job.name
}

output "glue_database" {
  value = aws_glue_catalog_database.ga4_db.name
}
