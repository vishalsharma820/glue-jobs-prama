pipeline {
  agent any
  tools {
        terraform 'Terraform-1.11.4'  // Name from Global Tool Configuration
    }
  environment {
    AWS_REGION = 'us-east-1'
    // Uncomment if you use credentials instead of EC2 role
    // AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    // AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/vishalsharma820/glue-jobs-prama.git'
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }

    stage('Terraform Validate') {
      steps {
        sh 'terraform validate'
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan -out=tfplan'
      }
    }

    stage('Terraform Apply') {
      when {
        branch 'main'
      }
      steps {
        input message: 'Approve to apply Terraform changes?'
        sh 'terraform apply -auto-approve tfplan'
      }
    }
  }

  post {
    failure {
      echo '❌ Build failed'
    }
    success {
      echo '✅ Terraform applied successfully'
    }
  }
}
