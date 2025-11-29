##########################################################
# loadbalancer.tf
# Public NLB -> Private ALB -> ECS target groups (A + B)
# - NLB target group uses target_type = "alb"
# - Ensure private ALB has a listener on the same port (80)
# - Add a short wait so ALB is ACTIVE before attaching to NLB TG
##########################################################

# Public NLB (internet-facing)
resource "aws_lb" "public_nlb" {
  name               = "public-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids
  # tags, idle_timeout etc. can be added as needed
}

# Private ALB (internal)
resource "aws_lb" "private_alb" {
  name               = "private-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_private_sg.id]
  subnets            = var.private_subnet_ids
}

# ----------------------------
# ALB Target Group for Service A (ALB -> ECS tasks)
# ----------------------------
resource "aws_lb_target_group" "tg_service_a" {
  name        = "tg-service-a"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ----------------------------
# ALB Target Group for Service B (ALB -> ECS tasks, internal or optional external)
# ----------------------------
resource "aws_lb_target_group" "tg_service_b" {
  name        = "tg-service-b"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path     = "/actuator/health"
    protocol = "HTTP"
  }
}

# ----------------------------
# ALB Listener (private ALB) - default forwards to Service A
# ----------------------------
resource "aws_lb_listener" "private_alb_http" {
  load_balancer_arn = aws_lb.private_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_service_a.arn
  }
}

# ----------------------------
# Optional: Listener rule for Service B (path-based)
# ----------------------------
resource "aws_lb_listener_rule" "service_b_rule" {
  listener_arn = aws_lb_listener.private_alb_http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_service_b.arn
  }

  condition {
    path_pattern {
      values = ["/service-b/*"]
    }
  }
}

# ----------------------------
# NLB target group that targets the ALB (target_type = "alb")
# ----------------------------
resource "aws_lb_target_group" "tg_nlb_to_alb" {
  name        = "tg-nlb-to-alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "alb"

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }
}


# ----------------------------
# Small sleep to avoid race condition: wait for ALB and its listener to be active
# ----------------------------
resource "time_sleep" "wait_for_alb" {
  depends_on      = [aws_lb_listener.private_alb_http]
  create_duration = "10s"
}

# ----------------------------
# Attach ALB (as target) to NLB target group
# Note: target_id is the ALB ARN when target_type = "alb"
# ----------------------------
resource "aws_lb_target_group_attachment" "alb_attach" {
  depends_on = [time_sleep.wait_for_alb]

  target_group_arn = aws_lb_target_group.tg_nlb_to_alb.arn
  target_id        = aws_lb.private_alb.arn
  port             = 80
}

# ----------------------------
# NLB listener forwards to the NLB target group (which points to ALB)
# ----------------------------
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.public_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_nlb_to_alb.arn
  }
}

##########################################################
# NOTES / EXTRAS
# - Ensure the ALB listener port (80) here matches tg_nlb_to_alb.port.
# - If you use HTTPS, adjust listener ports/protocols to 443 and TLS settings.
# - time_sleep avoids "ALB not active" race; you can increase to 20s if intermittent.
# - Make sure your security groups allow the relevant flows:
#     * public NLB (internet) -> NLB listener (TCP 80)
#     * NLB -> private ALB ENIs (these are internal)
#     * private ALB -> ECS tasks on 8080
##########################################################
