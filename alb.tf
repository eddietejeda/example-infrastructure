################################################################################
# Application Load Balancer
################################################################################

resource "aws_alb_target_group" "target_group" {
  name        = "${var.name}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/about"
    interval            = 300
    healthy_threshold   = 2
    timeout             = 5
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb" "load_balancer" {
  name            = "${var.name}-load-balancer"
  subnets         = module.vpc.public_subnets
  security_groups = [ 
    aws_security_group.load_balancer.id, 
    aws_security_group.web.id, 
    aws_security_group.workers.id, 
    aws_security_group.managed_services.id
  ]
}

# Forward all traffic from the ALB to the target group
resource "aws_alb_listener" "https_lb_listener" {
  load_balancer_arn = aws_alb.load_balancer.id
  certificate_arn   = aws_acm_certificate.primary_cert.arn
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = 443

  default_action {
    target_group_arn = aws_alb_target_group.target_group.id
    type             = "forward"
  }

  tags = local.tags
}

# Redirect all http traffic from the ALB to the https listener
resource "aws_alb_listener" "http_lb_listener" {
  load_balancer_arn = aws_alb.load_balancer.id
  port              = 80
  protocol          = "HTTP"

  ## Useful for testing
  # default_action {
  #   type = "fixed-response"

  #   fixed_response {
  #     content_type = "text/plain"
  #     message_body = "Fixed response content"
  #     status_code  = "200"
  #   }
  # }

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = local.tags
}