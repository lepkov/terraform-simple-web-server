terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

variable "aws_access_key" {
default = "XXXXXXXXXXXXXXXXXXXXXXX"
}
variable "aws_secret_key" {
default = "XXXXXXXXXXXXXXXXXXXXXXX"
}
variable "region" {
default = "eu-west-2"
}
variable "vpc" {
default = "vpc-XXXXXXXXXXXXXXXXXXXXXXX"
}
variable "subnet" {
default = "subnet-XXXXXXXXXXXXXXXXXXXXXXX"
}
variable "ec2_instance_type" {
default = "t2.micro"
}
variable "ec2_ami" {
default = "ami-0f540e9f488cfa27d"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http_sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc

  ingress {
    description      = "Allow acccess to http from the Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type
  subnet_id     = var.subnet
  security_groups = [aws_security_group.allow_http.id]
  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF
  tags = {
    Name = "WebServerInstance"
  } 
}

output "web_instance_ip" {
    value = aws_instance.web_server.public_ip
} 
