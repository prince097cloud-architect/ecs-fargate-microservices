#############################
# Security Group For VPCE
#############################

resource "aws_security_group" "vpce_sg" {
  name        = "vpce-sg"
  description = "Security group for VPC Endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [var.vpc_cidr]
    description     = "Allow TLS from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpce-sg"
  }
}

#############################
# ECR API Endpoint (Interface)
#############################
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-south-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.private_subnet_ids
  security_group_ids = [aws_security_group.vpce_sg.id]

  private_dns_enabled = true

  tags = {
    Name = "ecr-api-endpoint"
  }
}

#############################
# ECR DKR Endpoint (Interface)
#############################
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-south-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.private_subnet_ids
  security_group_ids = [aws_security_group.vpce_sg.id]

  private_dns_enabled = true

  tags = {
    Name = "ecr-dkr-endpoint"
  }
}

#############################
# S3 Gateway Endpoint
# ECR internally stores its image layers in S3
#############################
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-south-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = {
    Name = "s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-south-1.logs"
  vpc_endpoint_type = "Interface"

  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "vpce-cloudwatch-logs"
  }
}

##############################################
# SSM – Required for ECS Exec
##############################################
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true
}

##############################################
# SSM Messages – Required for ECS Exec
##############################################
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true
}

##############################################
# EC2 Messages – Required for ECS Exec
##############################################
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true
}


