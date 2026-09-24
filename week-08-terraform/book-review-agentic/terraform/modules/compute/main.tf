data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.name_prefix}-key"
  public_key = trimspace(file(pathexpand(var.public_key_path)))

  tags = {
    Name = "${var.name_prefix}-key"
  }
}

locals {
  web_subnets = { a = var.web_subnet_ids[0], b = var.web_subnet_ids[1] }
  app_subnets = { a = var.app_subnet_ids[0], b = var.app_subnet_ids[1] }
}

# --- Web tier ---

resource "aws_instance" "web" {
  for_each = local.web_subnets

  ami                         = data.aws_ssm_parameter.ubuntu_ami.insecure_value
  instance_type               = "t3.small"
  subnet_id                   = each.value
  vpc_security_group_ids      = [var.web_sg_id]
  iam_instance_profile        = var.web_instance_profile_name
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/templates/web_user_data.sh.tpl", {
    hostname_key          = each.key
    repo_url              = var.repo_url
    repo_ref              = var.repo_ref
    internal_alb_dns_name = var.internal_alb_dns_name
  })

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "oluwagbade-odimayo-web-${each.key}"
    Tier = "web"
  }
}

# --- Application tier ---

resource "aws_instance" "app" {
  for_each = local.app_subnets

  ami                         = data.aws_ssm_parameter.ubuntu_ami.insecure_value
  instance_type               = "t3.micro"
  subnet_id                   = each.value
  vpc_security_group_ids      = [var.app_sg_id]
  iam_instance_profile        = var.app_instance_profile_name
  associate_public_ip_address = false
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/templates/app_user_data.sh.tpl", {
    hostname_key               = each.key
    repo_url                   = var.repo_url
    repo_ref                   = var.repo_ref
    db_primary_address         = var.db_primary_address
    db_name                    = var.db_name
    db_username                = var.db_username
    db_password_parameter_name = var.db_password_parameter_name
    jwt_secret_parameter_name  = var.jwt_secret_parameter_name
    public_alb_dns_name        = var.public_alb_dns_name
    aws_region                 = var.aws_region
  })

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    encrypted             = true
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "oluwagbade-odimayo-app-${each.key}"
    Tier = "app"
  }
}

# --- Target group attachments ---

resource "aws_lb_target_group_attachment" "web" {
  for_each = aws_instance.web

  target_group_arn = var.web_tg_arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app" {
  for_each = aws_instance.app

  target_group_arn = var.app_tg_arn
  target_id        = each.value.id
  port             = 3001
}
