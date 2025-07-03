pipeline {
  agent any

  parameters {
    booleanParam(name: 'autoApprove', defaultValue: false, description: 'Apply infrastructure changes automatically?')
  }

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terragrunt Init & Plan') {
      steps {
        dir('envs/dev') {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Prama-sandbox']]) {
            sh '''
              terragrunt run-all init --terragrunt-non-interactive
              terragrunt run-all plan -out=planfile
            '''
          }
        }
      }
    }

    stage('Terragrunt Apply') {
      when {
        expression { return params.autoApprove }
      }
      steps {
        dir('envs/dev') {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Prama-sandbox']]) {
            sh '''
              terragrunt run-all apply --terragrunt-non-interactive
            '''
          }
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
