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
        git 'https://github.com/vishalsharma820/glue-jobs-prama.git'
      }
    }

    stage('Terragrunt Init & Plan') {
      steps {
        script {
          docker.image('alpine/terragrunt:latest').inside {
            dir('envs/dev') {
              withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Prama-sandbox']]) {
                sh '''
                  terragrunt run-all init
                  terragrunt run-all plan -out=planfile
                '''
              }
            }
          }
        }
      }
    }

    stage('Terragrunt Apply') {
      when {
        expression { return params.autoApprove }
      }
      steps {
        script {
          docker.image('alpine/terragrunt:latest').inside {
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
