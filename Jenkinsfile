pipeline {
    agent any

    parameters {
    choice(name: 'ENV', choices: ['dev', 'stage', 'prod'], description: 'Select environment to deploy to')
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

        stage('Terragrunt Plan') {
            steps {
                dir('deploy') {
                    sh '''
                    echo "Running 'make plan' for env: $ENV"
                    export PATH=$WORKSPACE:$PATH
                    make plan
                    '''
                }
            }
        }

        stage('Terragrunt Apply') {
            steps {
                dir('deploy') {
                    input message: "Do you want to proceed with terragrunt apply?", ok: "Apply"
                    sh '''
                    echo "Running 'make deploy' for env: $ENV"
                    export PATH=$WORKSPACE:$PATH
                    make deploy
                    '''
                }
            }
        }
    }
}
