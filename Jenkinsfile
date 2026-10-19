
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
                    sh 'terraform fmt -check'
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
                input(
                    message: 'Review Terraform plan. Approve infrastructure changes?',
                    ok: 'Approve and Apply'
                )
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

        stage('Start Nginx with AWS SSM') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        set -e

                        COMMAND_ID=$(aws ssm send-command \
                            --region us-east-1 \
                            --instance-ids i-059bafcf05c289dc0 \
                            --document-name AWS-RunShellScript \
                            --parameters 'commands=["sudo systemctl enable --now nginx","sudo systemctl is-active nginx"]' \
                            --query 'Command.CommandId' \
                            --output text)

                        echo "SSM Command ID: $COMMAND_ID"

                        for i in $(seq 1 12); do
                            STATUS=$(aws ssm get-command-invocation \
                                --region us-east-1 \
                                --command-id "$COMMAND_ID" \
                                --instance-id i-059bafcf05c289dc0 \
                                --query 'Status' \
                                --output text 2>/dev/null || true)

                            echo "SSM status: $STATUS"

                            if [ "$STATUS" = "Success" ]; then
                                aws ssm get-command-invocation \
                                    --region us-east-1 \
                                    --command-id "$COMMAND_ID" \
                                    --instance-id i-059bafcf05c289dc0 \
                                    --query 'StandardOutputContent' \
                                    --output text
                                exit 0
                            fi

                            if [ "$STATUS" = "Failed" ] || \
                               [ "$STATUS" = "Cancelled" ] || \
                               [ "$STATUS" = "TimedOut" ]; then
                                aws ssm get-command-invocation \
                                    --region us-east-1 \
                                    --command-id "$COMMAND_ID" \
                                    --instance-id i-059bafcf05c289dc0 \
                                    --output json
                                exit 1
                            fi

                            sleep 5
                        done

                        echo "SSM command did not finish within the wait period."
                        exit 1
                    '''
                }
            }
        }

        stage('Ansible Syntax Check') {
            steps {
                sh 'ansible-playbook -i ansible/inventory.ini ansible/setup.yml --syntax-check'
            }
        }

        stage('Configure Local Machine with Ansible') {
            steps {
                sh 'ansible-playbook -i ansible/inventory.ini ansible/setup.yml'
            }
        }

        stage('Verify Nginx over SSM') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        set -e

                        COMMAND_ID=$(aws ssm send-command \
                            --region us-east-1 \
                            --instance-ids i-059bafcf05c289dc0 \
                            --document-name AWS-RunShellScript \
                            --parameters 'commands=["systemctl is-active nginx"]' \
                            --query 'Command.CommandId' \
                            --output text)

                        echo "Verification Command ID: $COMMAND_ID"

                        for i in $(seq 1 12); do
                            STATUS=$(aws ssm get-command-invocation \
                                --region us-east-1 \
                                --command-id "$COMMAND_ID" \
                                --instance-id i-059bafcf05c289dc0 \
                                --query 'Status' \
                                --output text 2>/dev/null || true)

                            if [ "$STATUS" = "Success" ]; then
                                aws ssm get-command-invocation \
                                    --region us-east-1 \
                                    --command-id "$COMMAND_ID" \
                                    --instance-id i-059bafcf05c289dc0 \
                                    --query 'StandardOutputContent' \
                                    --output text
                                exit 0
                            fi

                            if [ "$STATUS" = "Failed" ] || \
                               [ "$STATUS" = "Cancelled" ] || \
                               [ "$STATUS" = "TimedOut" ]; then
                                aws ssm get-command-invocation \
                                    --region us-east-1 \
                                    --command-id "$COMMAND_ID" \
                                    --instance-id i-059bafcf05c289dc0 \
                                    --output json
                                exit 1
                            fi

                            sleep 5
                        done

                        echo "Nginx verification timed out."
                        exit 1
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Project 3 pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the failed stage logs.'
        }
    }
}
