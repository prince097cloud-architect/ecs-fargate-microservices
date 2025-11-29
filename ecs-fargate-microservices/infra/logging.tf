
#############################
# CloudWatch Log Groups
#############################

resource "aws_cloudwatch_log_group" "service_a_logs" {
  name              = "/ecs/service-a"
  retention_in_days = 7

  tags = {
    Name = "service-a-logs"
  }
}

resource "aws_cloudwatch_log_group" "service_b_logs" {
  name              = "/ecs/service-b"
  retention_in_days = 7

  tags = {
    Name = "service-b-logs"
  }
}

#############################
# IAM Permissions for ECS Tasks to push logs
#############################

resource "aws_iam_role_policy_attachment" "ecs_logs_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
