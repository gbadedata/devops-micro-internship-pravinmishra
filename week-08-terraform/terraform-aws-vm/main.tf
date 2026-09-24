# Assignment 2: AWS EC2 with a public network, provisioned with Terraform
# Author: Oluwagbade Odimayo

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "oluwagbade-tf-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "oluwagbade-tf-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "oluwagbade-tf-private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "oluwagbade-tf-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "oluwagbade-tf-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name        = "oluwagbade-tf-web-sg"
  description = "SSH from my IP only, HTTP from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "oluwagbade-tf-web-sg"
  }
}

# Only the public key is uploaded; the private key never leaves ~/.ssh
resource "aws_key_pair" "deployer" {
  key_name   = "oluwagbade-tf-key"
  public_key = file(pathexpand(var.public_key_path))
}

# Latest Ubuntu 22.04 AMI from AWS's public SSM parameter
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.insecure_value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    sed -i 's|<h1>Welcome to nginx!</h1>|<h1>Welcome to nginx!</h1><p>Deployed with Terraform by Oluwagbade Odimayo</p>|' /var/www/html/index.nginx-debian.html
    systemctl enable --now nginx
  EOF

  tags = {
    Name = "oluwagbade-odimayo-tf-ec2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR form, supplied via TF_VAR_my_ip_cidr"

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0))
    error_message = "my_ip_cidr must be a valid CIDR such as 203.0.113.10/32."
  }
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}
