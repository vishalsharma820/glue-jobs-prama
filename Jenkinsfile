pipeline {
    agent any

    environment {
        TERRAFORM_VERSION = '0.13.6'
        TERRAGRUNT_VERSION = '0.27.1'
        TERRAFORM_BIN = "${WORKSPACE}/terraform"
        TERRAGRUNT_BIN = "${WORKSPACE}/terragrunt"
        MODULES = 'iam-role glue-crawler glue-workflow glue-job-a glue-job-b glue-start-trigger glue-main-trigger'
        ENV = 'dev' // Change to 'stage' or 'prod' as needed
    }

    stages {
        stage('Install Terraform & Terragrunt') {
            steps {
                sh '''
                echo "Installing Terraform v$TERRAFORM_VERSION..."
                curl -L -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
                unzip -o terraform.zip -d .
                chmod +x terraform
                ./terraform --version

                echo "Installing Terragrunt v$TERRAGRUNT_VERSION..."
                curl -L -o terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64
                chmod +x terragrunt
                ./terragrunt --version
                '''
            }
        }

        stage('Terragrunt Plan via Makefile') {
            steps {
                dir('deploy') {
                    sh '''
                    echo "Updating PATH to include tools..."
                    export PATH=$WORKSPACE:$PATH

                    echo "Running 'make plan' with ENV=${ENV} and MODULES=${MODULES}"
                    make plan ENV=${ENV} MODULES="${MODULES}"
                    '''
                }
            }
        }

        stage('Terragrunt Apply via Makefile') {
            steps {
                dir('deploy') {
                    sh '''
                    echo "Updating PATH to include tools..."
                    export PATH=$WORKSPACE:$PATH

                    echo "Running 'make deploy' with ENV=${ENV} and MODULES=${MODULES}"
                    make deploy ENV=${ENV} MODULES="${MODULES}"
                    '''
                }
            }
        }
    }
}
