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
                    sh 'terraform init -backend=false'
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId, 'aws-access-key', varibale: 'AWS_ACCESS_KEY_ID')
                    string(credentialsId, 'aws-secret-key', varible: 'AWS_SECRET_ACCESS_KEY')
                ])
                dir('terraform') {
                    sh 'terraform plan -refresh=false -input=false'
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
