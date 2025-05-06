pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1'
    S3_BUCKET  = 'your-bucket-name'
    SCRIPT_KEY = 'glue-scripts/my_job.py'
  }

  stages {

    stage('Checkout') {
      steps {
        git 'https://github.com/your-repo/aws-glue-job.git'
      }
    }

    stage('Upload Glue Script to S3') {
      steps {
        withAWS(region: "${env.AWS_REGION}", credentials: 'aws-creds') {
          sh "aws s3 cp my_job.py s3://${S3_BUCKET}/${SCRIPT_KEY}"
        }
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan'
      }
    }

    stage('Terraform Apply - Deploy Glue Job') {
      steps {
        input message: "Approve Terraform Apply?"
        sh 'terraform apply -auto-approve'
      }
    }

  }

  post {
    success {
      echo 'Glue Job Created Successfully!'
    }
    failure {
      echo 'Pipeline Failed.'
    }
  }
}
