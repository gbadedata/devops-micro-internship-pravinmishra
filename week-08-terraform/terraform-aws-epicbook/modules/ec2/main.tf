# Only the public key is uploaded; the private key never leaves ~/.ssh
resource "aws_key_pair" "this" {
  key_name   = "${var.name_prefix}-key"
  public_key = file(pathexpand(var.public_key_path))
}

# Latest Ubuntu 24.04 LTS AMI from AWS's public SSM parameter
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_instance" "app" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.insecure_value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  # Installs Node.js, Nginx, Git and the MySQL client at first boot (no secrets)
  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  tags = { Name = "${var.name_prefix}-ec2" }
}
