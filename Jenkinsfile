pipeline {
  agent any

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/vishalsharma820/glue-jobs-prama.git'
      }
    }

    stage('Terraform Deploy') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Prama-sandbox']]) {
          sh '''
            terraform init
            terraform plan"
            terraform apply -auto-approve"
          '''
        }
      }
    }
  }

  post {
    success {
      echo "✅ Deployment succeeded"
    }
    failure {
      echo "❌ Deployment failed"
    }
  }
}
