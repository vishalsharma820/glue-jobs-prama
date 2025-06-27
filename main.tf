provider "aws" {
  region = var.region
}

# IAM Role for Glue
resource "aws_iam_role" "glue_role" {
  name = "jenkins-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS-managed Glue service role policy
resource "aws_iam_role_policy_attachment" "glue_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Custom S3 access policy for Glue
resource "aws_iam_policy" "glue_s3_access" {
  name        = "jenkins-glue-s3-access"
  description = "Allow Glue job to access scripts and temp directories in S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket}",
          "arn:aws:s3:::${var.s3_bucket}/*"
        ]
      }
    ]
  })
}

# Attach custom S3 access policy to Glue role
resource "aws_iam_role_policy_attachment" "glue_s3_access_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}

# Upload Glue script to S3
resource "aws_s3_object" "glue_script" {
  bucket = var.s3_bucket
  key    = var.script_key
  source = "${path.module}/scripts/myjob.py"
  etag   = filemd5("${path.module}/scripts/myjob.py")
}

# Define the Glue Job
resource "aws_glue_job" "jenkins_job" {
  name     = "jenkins-glue-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_object.glue_script.bucket}/${aws_s3_object.glue_script.key}"
    python_version  = "3"
  }

  glue_version      = "5.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  default_arguments = {
    "--TempDir"                          = "s3://${var.s3_bucket}/temp/"
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
  }

  timeout     = 10
  max_retries = 1
}
