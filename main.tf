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

# Attach AWS Glue service role policy
resource "aws_iam_role_policy_attachment" "glue_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Custom policy for S3 access
resource "aws_iam_policy" "glue_s3_access" {
  name        = "jenkins-glue-s3-access"
  description = "Allow Glue job to access S3"

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

resource "aws_iam_role_policy_attachment" "glue_s3_access_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_access.arn
}

# Upload job scripts to S3
resource "aws_s3_object" "glue_scripts" {
  for_each = {
    "jenkins-glue-job1" = "myjob.py"
    "jenkins-glue-job2" = "mysecondjob.py"
  }

  bucket = var.s3_bucket
  key    = "scripts/${each.value}"
  source = "${path.module}/scripts/${each.value}"
  etag   = filemd5("${path.module}/scripts/${each.value}")
}

# Job configuration map
locals {
  glue_jobs = {
    "jenkins-glue-job1" = {
      script_key        = "scripts/myjob.py"
      number_of_workers = 2
      worker_type       = "G.1X"
      glue_version      = "5.0"
      timeout           = 10
      max_retries       = 1
    },
    "jenkins-glue-job2" = {
      script_key        = "scripts/mysecondjob.py"
      number_of_workers = 3
      worker_type       = "G.2X"
      glue_version      = "5.0"
      timeout           = 15
      max_retries       = 2
    }
  }
}

# Reusable module for each job
module "glue_jobs" {
  for_each          = local.glue_jobs
  source            = "./modules/glue_job" 

  job_name          = each.key
  role_arn          = aws_iam_role.glue_role.arn
  script_location   = "s3://${var.s3_bucket}/${each.value.script_key}"
  number_of_workers = each.value.number_of_workers
  worker_type       = each.value.worker_type
  glue_version      = each.value.glue_version
  timeout           = each.value.timeout
  max_retries       = each.value.max_retries
  temp_dir          = "s3://${var.s3_bucket}/temp/"
}

# provider "aws" {
#   region = var.region
# }

# # IAM Role for Glue
# resource "aws_iam_role" "glue_role" {
#   name = "jenkins-glue-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "glue.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# # Attach AWS Glue service role policy
# resource "aws_iam_role_policy_attachment" "glue_attach" {
#   role       = aws_iam_role.glue_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
# }

# # Custom policy for S3 access
# resource "aws_iam_policy" "glue_s3_access" {
#   name        = "jenkins-glue-s3-access"
#   description = "Allow Glue job to access S3"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:ListBucket"
#         ],
#         Resource = [
#           "arn:aws:s3:::${var.s3_bucket}",
#           "arn:aws:s3:::${var.s3_bucket}/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "glue_s3_access_attach" {
#   role       = aws_iam_role.glue_role.name
#   policy_arn = aws_iam_policy.glue_s3_access.arn
# }

# # Upload script to S3
# resource "aws_s3_object" "glue_script" {
#   bucket = var.s3_bucket
#   key    = var.script_key
#   source = "${path.module}/scripts/myjob.py"
#   etag   = filemd5("${path.module}/scripts/myjob.py")
# }

# # Use module for Glue job
# module "jenkins_job" {
#   source = "./modules/glue_job"

#   job_name           = "jenkins-glue-job"
#   role_arn           = aws_iam_role.glue_role.arn
#   script_location    = "s3://${var.s3_bucket}/${var.script_key}"
#   number_of_workers  = 2
#   worker_type        = "G.1X"
#   glue_version       = "5.0"
#   timeout            = 10
#   max_retries        = 1
#   temp_dir           = "s3://${var.s3_bucket}/temp/"
# }
