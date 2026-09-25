# Four Ubuntu 24.04 VMs (web1, web2, app1, db1) for Ansible ad-hoc practice.

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------- Network ----------
resource "aws_vpc" "lab" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "a2-lab-vpc" }
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id
  tags   = { Name = "a2-lab-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "a2-lab-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }

  tags = { Name = "a2-lab-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------- Security groups ----------
# SSH is allowed ONLY from the controller's public IP. Every VM gets this group.
resource "aws_security_group" "ssh_from_controller" {
  name        = "a2-ssh-from-controller"
  description = "SSH from the Ansible controller IP only"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH from controller"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.controller_cidr]
  }

  egress {
    description = "All outbound (package installs)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "a2-ssh-from-controller" }
}

# HTTP is allowed from anywhere, but this group is attached ONLY to web hosts.
resource "aws_security_group" "web_http" {
  name        = "a2-web-http"
  description = "HTTP for web hosts only"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "a2-web-http" }
}

# ---------- Key pair and instances ----------
resource "aws_key_pair" "controller" {
  key_name   = "a2-controller-ed25519"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_instance" "server" {
  for_each = var.servers

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = aws_key_pair.controller.key_name

  # Web hosts get SSH + HTTP; app and db hosts get SSH only.
  vpc_security_group_ids = each.value.role == "web" ? [
    aws_security_group.ssh_from_controller.id,
    aws_security_group.web_http.id,
  ] : [aws_security_group.ssh_from_controller.id]

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  tags = {
    Name = "a2-${each.key}"
    Role = each.value.role
  }
}
