pipeline {
  agent any

//   tools {
//     terraform 'Terraform' // This should match the name in "Global Tool Configuration"
//   }

  environment {
    AWS_REGION = 'us-east-1'
    // Uncomment below if using credentials instead of instance profile or EC2 IAM role
    // AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    // AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/vishalsharma820/glue-jobs-prama.git'
      }
    }

    stage('Setup Terraform') {
      steps {
        script {
          def tfHome = tool name: 'Terraform', type: 'TerraformInstallation'
          env.PATH = "${tfHome}:${env.PATH}"
        }
        sh 'terraform version' // Verify Terraform is accessible
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
