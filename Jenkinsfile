pipeline {
    agent any

    parameters {
        string(name: 'ENV', defaultValue: 'dev', description: 'Environment to deploy to (e.g., dev, stage, prod)')
        string(name: 'MODULES', defaultValue: 'iam-role glue-crawler glue-workflow glue-job-a glue-job-b glue-start-trigger glue-main-trigger', description: 'Modules to include (space-separated)')
    }

    environment {
        TERRAFORM_VERSION = '0.13.6'
        TERRAGRUNT_VERSION = '0.27.1'
        TERRAFORM_BIN = "${WORKSPACE}/terraform"
        TERRAGRUNT_BIN = "${WORKSPACE}/terragrunt"
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

                    echo "Running 'make plan' in $ENV environment with modules: $MODULES"
                    make plan ENV=$ENV MODULES="$MODULES"
                    '''
                }
            }
        }
    }
}
