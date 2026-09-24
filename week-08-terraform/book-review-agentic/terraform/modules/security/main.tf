# --- Security Groups ---

resource "aws_security_group" "alb_public" {
  name        = "${var.name_prefix}-sg-alb-public"
  description = "Public ALB security group for the Book Review App"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-sg-alb-public"
    Tier = "web"
  }
}

resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-sg-web"
  description = "Web tier security group for the Book Review App"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-sg-web"
    Tier = "web"
  }
}

resource "aws_security_group" "alb_internal" {
  name        = "${var.name_prefix}-sg-alb-internal"
  description = "Internal ALB security group for the Book Review App"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-sg-alb-internal"
    Tier = "app"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-sg-app"
  description = "Application tier security group for the Book Review App"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-sg-app"
    Tier = "app"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-sg-db"
  description = "Database tier security group for the Book Review App"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-sg-db"
    Tier = "db"
  }
}

# --- Public ALB SG rules ---

resource "aws_vpc_security_group_ingress_rule" "alb_public_http_in" {
  security_group_id = aws_security_group.alb_public.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP from the internet"
}

resource "aws_vpc_security_group_egress_rule" "alb_public_to_web" {
  security_group_id            = aws_security_group.alb_public.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Forward HTTP to the web tier"
}

# --- Web tier SG rules ---

resource "aws_vpc_security_group_ingress_rule" "web_http_in" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.alb_public.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allow HTTP from the public ALB"
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh_in" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = var.my_ip_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allow SSH from the owner's IP"
}

resource "aws_vpc_security_group_egress_rule" "web_to_alb_internal" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.alb_internal.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Forward HTTP to the internal ALB"
}

resource "aws_vpc_security_group_egress_rule" "web_http_out" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow outbound HTTP for OS package updates"
}

resource "aws_vpc_security_group_egress_rule" "web_https_out" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow outbound HTTPS for npm, SSM and GitHub"
}

# --- Internal ALB SG rules ---

resource "aws_vpc_security_group_ingress_rule" "alb_internal_http_in" {
  security_group_id            = aws_security_group.alb_internal.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  description                  = "Allow HTTP from the web tier"
}

resource "aws_vpc_security_group_egress_rule" "alb_internal_to_app" {
  security_group_id            = aws_security_group.alb_internal.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 3001
  to_port                      = 3001
  ip_protocol                  = "tcp"
  description                  = "Forward traffic to the application tier"
}

# --- Application tier SG rules ---

resource "aws_vpc_security_group_ingress_rule" "app_3001_in" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb_internal.id
  from_port                    = 3001
  to_port                      = 3001
  ip_protocol                  = "tcp"
  description                  = "Allow application traffic from the internal ALB"
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "Allow MySQL traffic to the database tier"
}

resource "aws_vpc_security_group_egress_rule" "app_http_out" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow outbound HTTP for OS package updates"
}

resource "aws_vpc_security_group_egress_rule" "app_https_out" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow outbound HTTPS for npm, SSM and GitHub"
}

# --- Database tier SG rules ---
# No egress rules: AWS creates an allow-all egress rule on every new security
# group, but Terraform removes it on creation, so the DB tier is fully closed
# on outbound traffic.

resource "aws_vpc_security_group_ingress_rule" "db_3306_in" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "Allow MySQL traffic from the application tier"
}

# --- IAM roles and instance profiles: separate for web and app tiers ---

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Web tier: SSM Session Manager access only, no secrets policy.

resource "aws_iam_role" "web" {
  name               = "${var.name_prefix}-web-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.name_prefix}-web-role"
  }
}

resource "aws_iam_role_policy_attachment" "web_ssm_core" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.name_prefix}-web-profile"
  role = aws_iam_role.web.name

  tags = {
    Name = "${var.name_prefix}-web-profile"
  }
}

# App tier: SSM Session Manager access plus read-only access to the two
# SecureString parameters it needs at boot (db password, JWT secret).

resource "aws_iam_role" "app" {
  name               = "${var.name_prefix}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.name_prefix}-app-role"
  }
}

resource "aws_iam_role_policy_attachment" "app_ssm_core" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "app_ssm_read" {
  statement {
    sid     = "ReadBookReviewSecrets"
    effect  = "Allow"
    actions = ["ssm:GetParameter"]
    resources = [
      aws_ssm_parameter.db_password.arn,
      aws_ssm_parameter.jwt_secret.arn,
    ]
  }
}

resource "aws_iam_role_policy" "app_ssm_read" {
  name   = "${var.name_prefix}-app-ssm-read"
  role   = aws_iam_role.app.name
  policy = data.aws_iam_policy_document.app_ssm_read.json
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.name_prefix}-app-profile"
  role = aws_iam_role.app.name

  tags = {
    Name = "${var.name_prefix}-app-profile"
  }
}

# --- SSM SecureString parameters ---
# value_wo is a write-only argument: the secret is never persisted to state.
# To rotate a secret, bump value_wo_version (e.g. 1 -> 2) alongside the new
# TF_VAR_* value -- changing the underlying variable alone will not trigger
# an update.

resource "aws_ssm_parameter" "db_password" {
  name             = "/${var.name_prefix}/db_password"
  type             = "SecureString"
  value_wo         = var.db_password
  value_wo_version = 1

  tags = {
    Name = "${var.name_prefix}-db-password"
  }
}

resource "aws_ssm_parameter" "jwt_secret" {
  name             = "/${var.name_prefix}/jwt_secret"
  type             = "SecureString"
  value_wo         = var.jwt_secret
  value_wo_version = 1

  tags = {
    Name = "${var.name_prefix}-jwt-secret"
  }
}
