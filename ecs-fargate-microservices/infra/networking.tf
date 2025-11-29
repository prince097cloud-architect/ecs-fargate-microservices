resource "aws_security_group" "alb_private_sg" {
    name        = "private-alb-sg"
    description = "ALB in private subnets"
    vpc_id      = var.vpc_id

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [aws_security_group.nlb_public_sg.id] # allow only NLB SG
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "nlb_public_sg" {
    name        = "nlb-public-sg"
    description = "NLB public sg (not strictly required for NLB)"
    vpc_id      = var.vpc_id

    # NLB uses ENIs; allow inbound 80 from 0.0.0.0/0
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ecs_service_sg" {
    name        = "ecs-service-sg"
    description = "SG for ECS tasks (services)"
    vpc_id      = var.vpc_id

    # allow ALB to talk to tasks
    ingress {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        security_groups = [aws_security_group.alb_private_sg.id]
    }

    # allow tasks to call Cloud Map DNS and other AWS services
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "allow_internal_8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_service_sg.id
  self              = true
}

