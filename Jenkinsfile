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
