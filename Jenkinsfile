pipeline {
  agent any

  environment {
    AWS_REGION = 'us-east-1' // replace with your region or use a Jenkins parameter
  }

  options {
    timestamps()
  }

  stages {
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          terraform init
        '''
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''
          terraform plan -out=tfplan
        '''
      }
    }

    stage('Terraform Apply') {
      when {
        branch 'main' // restrict apply only to main branch
      }
      steps {
        input message: 'Approve Terraform Apply?'
        sh '''
          terraform apply -auto-approve tfplan
        '''
      }
    }
  }

  post {
    failure {
      echo 'Terraform deployment failed.'
    }
    success {
      echo 'Terraform deployment completed.'
    }
  }
}
