pipeline {
    agent any

    environment {
        TERRAFORM_VERSION = '0.13.6'
        TERRAGRUNT_VERSION = '0.27.1'
        TERRAFORM_BIN = "${WORKSPACE}/terraform"
        TERRAGRUNT_BIN = "${WORKSPACE}/terragrunt"
        MODULES = 'iam-role glue-crawler glue-workflow glue-job-a glue-job-b glue-start-trigger glue-main-trigger'
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

        stage('Terragrunt Plan per Module') {
            steps {
                script {
                    def modules = env.MODULES.split()
                    modules.each { module ->
                        dir("deploy/envs/dev/${module}") {
                            sh '''
                            echo "==============================================="
                            echo "Running Terragrunt plan in $(pwd)..."

                            rm -rf .terragrunt-cache || true
                            export PATH=$WORKSPACE:$PATH

                            terragrunt init -reconfigure
                            terragrunt plan

                            echo "==============================================="
                            '''
                        }
                    }
                }
            }
        }

        stage('Terragrunt Apply per Module') {
            steps {
                script {
                    def modules = env.MODULES.split()
                    modules.each { module ->
                        dir("deploy/envs/dev/${module}") {
                            sh '''
                            echo "==============================================="
                            echo "Running Terragrunt apply in $(pwd)..."

                            rm -rf .terragrunt-cache || true
                            export PATH=$WORKSPACE:$PATH

                            terragrunt apply -auto-approve

                            echo "==============================================="
                            '''
                        }
                    }
                }
            }
        }
    }
}
