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
  ami                    = "ami-0856027a77429315a"
  instance_type          = "t3.small"
  subnet_id              = "subnet-0ef512135f651951d"
  vpc_security_group_ids = [aws_security_group.project3.id]

  tags = {
    Name = "project3-ansible-server"
  }
}

output "ec2_public_ip" {
  value = aws_instance.project3.public_ip
}

resource "aws_security_group" "project3" {
  name        = "project3-ansible-sg"
  description = "SSH and HTTP access for project 3"
  vpc_id      = "vpc-072c715a4cdef186f"

  ingress {
    description = "SSH from admin IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["5.14.136.147/32"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project3-ansible-sg"
  }

}