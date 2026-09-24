# HTTP only: no domain or certificate for this capstone, so both listeners
# serve plain HTTP on port 80. Database traffic still uses TLS.

# --- Public ALB (internet-facing) ---

resource "aws_lb" "public" {
  name                       = "${var.name_prefix}-alb-pub"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = var.web_subnet_ids
  security_groups            = [var.alb_public_sg_id]
  drop_invalid_header_fields = true
  enable_deletion_protection = false

  tags = {
    Name = "${var.name_prefix}-alb-pub"
    Tier = "web"
  }
}

resource "aws_lb_target_group" "web" {
  name                 = "${var.name_prefix}-tg-web"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    path              = "/"
    matcher           = "200"
    healthy_threshold = 2
    interval          = 15
    timeout           = 5
    port              = "traffic-port"
    protocol          = "HTTP"
  }

  tags = {
    Name = "${var.name_prefix}-tg-web"
    Tier = "web"
  }
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# --- Internal ALB (app tier, private) ---

resource "aws_lb" "internal" {
  name                       = "${var.name_prefix}-alb-int"
  internal                   = true
  load_balancer_type         = "application"
  subnets                    = var.app_subnet_ids
  security_groups            = [var.alb_internal_sg_id]
  drop_invalid_header_fields = true
  enable_deletion_protection = false

  tags = {
    Name = "${var.name_prefix}-alb-int"
    Tier = "app"
  }
}

resource "aws_lb_target_group" "app" {
  name                 = "${var.name_prefix}-tg-app"
  port                 = 3001
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    path              = "/"
    matcher           = "200"
    healthy_threshold = 2
    interval          = 15
    timeout           = 5
    port              = "traffic-port"
    protocol          = "HTTP"
  }

  tags = {
    Name = "${var.name_prefix}-tg-app"
    Tier = "app"
  }
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
