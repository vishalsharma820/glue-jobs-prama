provider "aws" {
  region = var.region
}

# === Unique S3 Bucket for GA4 Data ===
resource "aws_s3_bucket" "ga4_data_bucket" {
  bucket = var.data_bucket_name
}

# === Unique S3 Bucket for Script and Credentials ===
resource "aws_s3_bucket" "ga4_script_bucket" {
  bucket = var.script_bucket_name
}

# Upload Python Script
resource "aws_s3_object" "script_upload" {
  bucket = aws_s3_bucket.ga4_script_bucket.id
  key    = var.script_key
  source = "${path.module}/script/ga4_traffic_job.py"
  etag   = filemd5("${path.module}/script/ga4_traffic_job.py")
}

# Upload Google Credentials
resource "aws_s3_object" "creds_upload" {
  bucket = aws_s3_bucket.ga4_script_bucket.id
  key    = var.credentials_key
  source = "${path.module}/config/config.json"
  etag   = filemd5("${path.module}/config/config.json")
}

# === IAM Role for Glue ===
resource "aws_iam_role" "glue_role" {
  name = "GlueGA4RoleTF"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "glue_policy_attach" {
  name       = "glue-managed-policy-attach"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
# Attach AmazonS3FullAccess
resource "aws_iam_policy_attachment" "s3_full_access_attach" {
  name       = "s3-full-access-attach"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach CloudWatchLogsFullAccess
resource "aws_iam_policy_attachment" "cloudwatch_logs_full_access_attach" {
  name       = "cloudwatch-logs-full-access-attach"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
resource "aws_iam_role_policy" "glue_custom_policy" {
  name = "GlueS3AccessPolicyTF"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:*"],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.ga4_data_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.ga4_data_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.ga4_script_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.ga4_script_bucket.bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = ["glue:*", "lakeformation:GetDataAccess"],
        Resource = "*"
      }
    ]
  })
}
# Allow this role to be passed (iam:PassRole)
resource "aws_iam_role_policy" "glue_passrole_policy" {
  name = "GluePassRolePolicy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = aws_iam_role.glue_role.arn
      }
    ]
  })
}

# === Unique Glue Database ===
resource "aws_glue_catalog_database" "ga4_db" {
  name = var.database_name
}

# === Unique Glue Job ===
resource "aws_glue_job" "ga4_traffic_job" {
  name     = var.glue_job_name
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.ga4_script_bucket.bucket}/${var.script_key}"
  }

  default_arguments = {
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--enable-metrics" = "true"
    "--enable-glue-datacatalog"="true"
    "--TempDir"                          = "s3://${aws_s3_bucket.ga4_data_bucket.bucket}/tmp/"
    # "--additional-python-modules"       = "google-analytics-data==0.13.2,awswrangler==3.3.0,pandas==1.3.5,numpy==1.21.4"
    "--additional-python-modules" = "google-analytics-data==0.13.2,google-api-core==2.17.1,protobuf==4.25.3,grpcio==1.62.1,grpcio-status==1.62.1,setuptools==68.2.2,awswrangler==3.3.0,pandas==1.3.5,numpy==1.21.4"

  }

  glue_version       = "5.0"
  number_of_workers  = 5
  worker_type        = "G.1X"
}
