pipeline {
  agent any

  parameters {
    booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
  }

  environment {
    AWS_DEFAULT_REGION = 'us-east-1'
    TF_VERSION = '0.13.6'
    TF_BIN = "${WORKSPACE}/terraform"
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/vishalsharma820/glue-jobs-prama.git'
      }
    }

    stage('Install Terraform v0.13.6') {
      steps {
        sh '''
          echo "Downloading Terraform ${TF_VERSION}..."
          curl -s -o terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
          unzip -o terraform.zip -d .
          chmod +x terraform
        '''
      }
    }

    stage('Terraform Init & Plan') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Prama-sandbox']]) {
          sh '''
            ${TF_BIN} version
            ${TF_BIN} init
            ${TF_BIN} plan -out=tfplan
          '''
        }
      }
    }

    stage('Terraform Apply') {
      when {
        expression { return params.autoApprove }
      }
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Prama-sandbox']]) {
          sh '${TF_BIN} apply -auto-approve tfplan'
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
