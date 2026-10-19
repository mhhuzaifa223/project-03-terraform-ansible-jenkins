# Project 3: Terraform, Ansible and Jenkins

## About the Project

This project is about automating basic infrastructure tasks using Terraform, Ansible, Jenkins and AWS.

I built this project to understand how infrastructure can be created and managed through a Jenkins pipeline instead of running every command manually.

Terraform manages the AWS infrastructure, Jenkins runs the pipeline, AWS Systems Manager (SSM) runs commands on the EC2 instance, and Ansible performs Linux health checks.

## Tools Used

- AWS EC2
- AWS Systems Manager (SSM)
- Terraform
- Jenkins
- Ansible
- AWS S3 for Terraform remote state
- Git and GitHub
- Nginx

## What I Worked On

- Created and managed AWS infrastructure using Terraform.
- Configured remote Terraform state in an S3 bucket.
- Created a Jenkins pipeline to validate Terraform configuration, generate a plan and apply approved changes.
- Added a manual approval step before applying infrastructure changes.
- Used AWS Systems Manager to start and verify Nginx on the EC2 instance.
- Used Ansible to check the Linux user, system uptime, disk usage and memory.
- Stored the project files in GitHub.

## How the Pipeline Works

1. Jenkins checks out the project from GitHub.
2. Terraform formatting and validation checks run.
3. Terraform initializes and generates an execution plan.
4. The pipeline waits for manual approval.
5. Terraform applies the approved plan.
6. AWS SSM starts Nginx on the EC2 instance.
7. Ansible checks the Linux environment on the Jenkins machine.
8. AWS SSM verifies that Nginx is running on EC2.

## Testing

I tested the Ansible playbook manually and confirmed that the health checks completed successfully.

The playbook reported the current user, system uptime, root filesystem usage and memory information.

The Jenkins pipeline also completed successfully with the SSM-based setup.

## What I Learned

This project helped me practise Terraform workflows, Jenkins pipeline stages, manual approvals, AWS SSM commands and Ansible playbooks.

I also learned why using SSM can be useful when direct SSH access to an EC2 instance is not working.

## Repository Structure

```text
project-3-terraform-ansible-jenkins/
├── Jenkinsfile
├── terraform/
├── ansible/
│   ├── inventory.ini
│   └── setup.yml
└── README.md
```