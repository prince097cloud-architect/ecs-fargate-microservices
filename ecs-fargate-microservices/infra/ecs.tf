#############################################
# ECS Cluster
#############################################
resource "aws_ecs_cluster" "this" {
  name = "Prince-ecs-cluster"
}
############################################
# IAM Role for ECS Task Runtime (taskRoleArn)
############################################
resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole-demo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Optional policy — allow SSM Exec agent to run properly
resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name = "ecsTaskRolePolicy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = "*"
      }
    ]
  })
}

#############################################
# IAM Role For ECS Task Execution
#############################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole-demo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ecs_exec_policy" {
  name = "ecs-exec-ssm-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = "*"
      }
    ]
  })
}
#############################################

# Attach required ECS execution policies
resource "aws_iam_role_policy_attachment" "ecs_task_exec_base" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_ecr" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}




#############################################
# TASK DEFINITION: SERVICE A
#############################################
resource "aws_ecs_task_definition" "service_a_td" {
  family                   = "service-a"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn 
  
  
 

  container_definitions = jsonencode([
    {
      name      = "service-a"
      image     = var.service_a_image
      essential = true

      portMappings = [
        {
          containerPort = 8080
        }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/actuator/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 40
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.region
          awslogs-group         = "/ecs/service-a"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

#############################################
# TASK DEFINITION: SERVICE B
#############################################
resource "aws_ecs_task_definition" "service_b_td" {
  family                   = "service-b"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "service-b"
      image     = var.service_b_image
      essential = true

      portMappings = [
        {
          containerPort = 8080
        }
      ]

      # service-b reaches service-a via CloudMap (DNS)
      environment = [
        { name = "SERVICE_A_HOST", value = "service-a.service.local" },
        { name = "MAX_RETRIES", value = "60" },
        { name = "SLEEP_SEC",  value = "5"  }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/actuator/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 40
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.region
          awslogs-group         = "/ecs/service-b"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

#############################################
# ECS SERVICE: SERVICE A
#############################################
resource "aws_ecs_service" "service_a" {
  name            = "service-a"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.service_a_td.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  enable_execute_command = true
  

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_service_a.arn
    container_name   = "service-a"
    container_port   = 8080
  }

  service_registries {
    registry_arn = aws_service_discovery_service.svc_a.arn
  }

  depends_on = [
    aws_lb_listener.private_alb_http
  ]
}

#############################################
# ECS SERVICE: SERVICE B
#############################################
resource "aws_ecs_service" "service_b" {
  name            = "service-b"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.service_b_td.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  enable_execute_command = true
  

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.svc_b.arn
  }

  depends_on = [
    aws_lb_listener.private_alb_http
  ]
}
