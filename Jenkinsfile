pipeline {
  agent {
    docker {
      image 'alpine/terragrunt:latest' // Or use your custom image with terraform + terragrunt
      args '-v $HOME/.aws:/root/.aws'  // Optional: Mount AWS credentials if needed
    }
  }

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
        dir('envs/dev') {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Prama-sandbox']]) {
            sh '''
              terragrunt run-all init
              terragrunt run-all plan
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
              terragrunt run-all apply --terragrunt-non-interactive --terragrunt-include-external-dependencies
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
