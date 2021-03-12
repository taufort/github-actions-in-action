locals {
  main_alb_name = "${var.tags["project"]}-alb"
}

resource "aws_lb" "main_alb" {
  name               = local.main_alb_name
  load_balancer_type = "application"
  internal           = false

  subnets = module.main_vpc.public_subnets_ids

  security_groups = [
    aws_security_group.main_alb_security_group.id,
  ]

  idle_timeout = 60

  tags = var.tags
}

output "main_alb_name" {
  value = aws_lb.main_alb.name
}

output "main_alb_arn_suffix" {
  value = aws_lb.main_alb.arn_suffix
}

output "main_alb_dns_name" {
  value = aws_lb.main_alb.dns_name
}

output "main_alb_zone_id" {
  value = aws_lb.main_alb.zone_id
}

resource "aws_lb_listener" "main_alb_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }
}

output "main_alb_listener_arn" {
  value = aws_lb_listener.main_alb_listener.arn
}

resource "aws_security_group" "main_alb_security_group" {
  name        = local.main_alb_name
  description = "${local.main_alb_name} ALB security group"
  vpc_id      = module.main_vpc.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    description = "Allow HTTP from internet"
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = module.main_vpc.private_subnets_cidr_blocks
    description = "Allow traffic towards private subnets CIDR blocks"
  }

  tags = var.tags
}

output "main_alb_security_group_id" {
  value = aws_security_group.main_alb_security_group.id
}

resource "aws_lb_target_group" "main_alb_target_group" {
  name        = local.main_alb_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.main_vpc.vpc_id

  deregistration_delay = 30

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    port                = 8080
    path                = "/actuator/health"
    interval            = 10
    matcher             = "200"
  }

  tags = var.tags
}

output "main_alb_target_group_arn" {
  value = aws_lb_target_group.main_alb_target_group.arn
}