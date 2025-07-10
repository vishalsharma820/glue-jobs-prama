pipeline {
    agent any

    environment {
        TERRAFORM_VERSION = '0.13.6'
        TERRAGRUNT_VERSION = '0.27.1'
        TERRAFORM_BIN = "${WORKSPACE}/terraform"
        TERRAGRUNT_BIN = "${WORKSPACE}/terragrunt"
        MODULES = 'iam-role glue-job-a glue-job-b'
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

        stage('Terraform Apply per Module') {
            steps {
                script {
                    def modules = env.MODULES.split()
                    modules.each { module ->
                        dir("envs/dev/${module}") {
                            sh '''
                            echo "==============================================="
                            echo "Running Terragrunt in $(pwd)..."

                            echo "Cleaning Terragrunt cache if present..."
                            rm -rf .terragrunt-cache || true

                            echo "Initializing Terragrunt backend..."
                            ''' + "${TERRAGRUNT_BIN} init -reconfigure -backend=true" + '''

                            echo "Applying module: ${module}..."
                            ''' + "${TERRAGRUNT_BIN} apply -auto-approve" + '''
                            echo "==============================================="
                            '''
                        }
                    }
                }
            }
        }
    }
}
