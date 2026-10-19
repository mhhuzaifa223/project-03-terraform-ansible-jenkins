pipeline {
    agent any 
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Validation') {
            steps {
                dir('terraform') {
                    sh 'terraform fmt  -check'
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir('terraform') {
                        sh 'terraform init -input=false'
                        sh 'terraform plan -input=false -out=tfplan'
                    }
                }
            }      
        }

        stage('Approval') {
            steps {
                input message: 'Review terraform Plan. Approve Infrastrcuture Changes.?',
                ok: 'Approve and Apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir('terraform') {
                        sh 'terraform apply -input=false tfplan'
                    }
                }
            }
        }

        stage('Configure EC2 via SSM') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        set -e
                        export AWS_DEFAULT_REGION=us-east-1

                        COMMAND_ID=$(aws ssm send-command) \
                          --instance-ids i-059bafcf05c289dc0 \
                          --document-name AWS-RunShellScript \
                          --parameters 'commands=["sudo systemctl enable --now nginx","sudo systemctl is-active nginx"]' \
                          --query 'Command.CommandId' \
                          --output text)
                        
                        echo "SSM Command ID: $COMMAND_ID"

                        while true; do
                          STATUS=$(aws ssm get-command-invocation \
                            --command-id "$COMMAND_ID" \
                            --instance-id i-059bafcf05c289dc0 \
                            --query Status \
                            --output text 2>/dev/null || echo "Pending")

                          echo "EC2 configuration status: $STATUS"

                          case "$STATUS" in
                            Success) break ;;
                            Failed|Cancelled|TimedOut)
                              aws ssm get-command-invocation \
                                --command-id "$COMMAND_ID" \
                                --instance-id i-059bafcf05c289dc0 \
                                --query '[StandardOutputContent,StandardErrorContent]' \
                                --output text
                              exit 1
                              ;;
                          esac

                          sleep 5
                        done

                        aws ssm get-command-invocation \
                          --command-id "$COMMAND_ID" \
                          --instance-id i-059bafcf05c289dc0 \
                          --query '[Status,StandardOutputContent]' \
                          --output text
                    '''
                }
            }
        }

        stage('Ansible syntax check') {
            steps {
                sh 'ansible-playbook -i ansible/inventory.ini ansible/setup.yml --syntax-check'
            }
        }

        stage('Run ansible') {
            steps {
                sh 'ansible-playbook -i ansible/inventory.ini ansible/setup.yml'
            }
        }
    }

    post {
        success {
            echo 'Projecy 3 pipeline completed usccessfully'
        }
        failure {
            echo 'Pipeline failed. Check the stage logs'
        }
    }
     
}
