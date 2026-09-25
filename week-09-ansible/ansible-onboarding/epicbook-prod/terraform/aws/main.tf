# EpicBook infrastructure: one Ubuntu 24.04 app server and a private Amazon RDS for MySQL database.

data "aws_availability_zones" "available" {
  state = "available"
}

# Latest Ubuntu 24.04 LTS AMI from Canonical's public SSM parameter
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# ---------- Network ----------
resource "aws_vpc" "main" {
  cidr_block           = "10.40.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.40.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name_prefix}-public" }
}

# RDS needs a subnet group spanning two availability zones; neither subnet has an internet route.
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.40.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags              = { Name = "${var.name_prefix}-db-a" }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.40.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags              = { Name = "${var.name_prefix}-db-b" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------- Security groups ----------
resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "EpicBook app server: SSH from the controller only, HTTP from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from the Ansible controller only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.controller_cidr]
  }

  ingress {
    description = "HTTP from anywhere (Nginx)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound (packages, GitHub, npm)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-app-sg" }
}

# MySQL 3306 is reachable ONLY from the app server's security group, never from the internet.
resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "EpicBook database: MySQL from the app server security group only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from the EpicBook app server only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = { Name = "${var.name_prefix}-db-sg" }
}

# ---------- Application server ----------
resource "aws_key_pair" "controller" {
  key_name   = "${var.name_prefix}-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_instance" "app" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.insecure_value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = aws_key_pair.controller.key_name

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 12
    encrypted   = true
  }

  tags = { Name = "${var.name_prefix}-app" }
}

# ---------- Managed MySQL ----------
resource "aws_db_subnet_group" "db" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]
  tags       = { Name = "${var.name_prefix}-db-subnets" }
}

resource "aws_db_instance" "mysql" {
  identifier     = "${var.name_prefix}-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = false

  # Lab settings: no automated backups or final snapshot, so destroy is quick and leaves nothing billing
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = { Name = "${var.name_prefix}-mysql" }
}
