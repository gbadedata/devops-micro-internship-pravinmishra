locals {
  web_subnet_cidrs = {
    a = "10.0.1.0/24"
    b = "10.0.2.0/24"
  }

  app_subnet_cidrs = {
    a = "10.0.11.0/24"
    b = "10.0.12.0/24"
  }

  db_subnet_cidrs = {
    a = "10.0.21.0/24"
    b = "10.0.22.0/24"
  }

  az_by_key = {
    a = var.azs[0]
    b = var.azs[1]
  }
}

# --- VPC and Internet Gateway ---

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

# --- Subnets ---

resource "aws_subnet" "web" {
  for_each = local.web_subnet_cidrs

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = local.az_by_key[each.key]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-web-${each.key}"
    Tier = "web"
  }
}

resource "aws_subnet" "app" {
  for_each = local.app_subnet_cidrs

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = local.az_by_key[each.key]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-app-${each.key}"
    Tier = "app"
  }
}

resource "aws_subnet" "db" {
  for_each = local.db_subnet_cidrs

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = local.az_by_key[each.key]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-db-${each.key}"
    Tier = "db"
  }
}

# --- NAT Gateway (single, in Web subnet A, per agreed cost trade-off) ---

resource "aws_eip" "nat" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.name_prefix}-nat-eip"
    Tier = "web"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web["a"].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.name_prefix}-nat"
    Tier = "web"
  }
}

# --- Route Tables ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-rt-public"
    Tier = "web"
  }
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-rt-app"
    Tier = "app"
  }
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-rt-db"
    Tier = "db"
  }
}

# --- Route Table Associations ---

resource "aws_route_table_association" "web" {
  for_each = aws_subnet.web

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app" {
  for_each = aws_subnet.app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "db" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.db.id
}
