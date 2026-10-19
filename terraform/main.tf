terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "huzaifa-project3-tfstate-482972685106"
    key          = "project-3/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "project3" {
  bucket_prefix = "huzaifa-project3-demo-"
}

resource "aws_instance" "project3" {
  ami           = "ami-0856027a77429315a"
  instance_type = "t3.small"

  tags = {
    Name = "project3-ansible-server"
  }
}

output "ec2_public_ip" {
  value = aws_instance.project3.public_ip
}