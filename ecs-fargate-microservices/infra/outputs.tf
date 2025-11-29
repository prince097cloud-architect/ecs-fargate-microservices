# Public NLB DNS (external access)
output "public_nlb_dns" {
  description = "Public DNS of the NLB"
  value       = aws_lb.public_nlb.dns_name
}

# Internal ALB DNS (internal access)
output "private_alb_dns" {
  description = "Internal DNS of the ALB"
  value       = aws_lb.private_alb.dns_name
}

# ECS cluster
output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.this.name
}

# ECS service names
output "ecs_service_a_name" {
  value = aws_ecs_service.service_a.name
}

output "ecs_service_b_name" {
  value = aws_ecs_service.service_b.name
}

# Useful target groups
output "tg_service_a_arn" {
  value = aws_lb_target_group.tg_service_a.arn
}

output "tg_service_b_arn" {
  value = aws_lb_target_group.tg_service_b.arn
}
output "ecr_service_a" { value = aws_ecr_repository.service_a.repository_url }
output "ecr_service_b" { value = aws_ecr_repository.service_b.repository_url }


# ecr_repo_service_a = "580069881439.dkr.ecr.ap-south-1.amazonaws.com/service-a"
# ecr_repo_service_b = "580069881439.dkr.ecr.ap-south-1.amazonaws.com/service-b"
# ecr_service_a = "580069881439.dkr.ecr.ap-south-1.amazonaws.com/service-a"
# ecr_service_b = "580069881439.dkr.ecr.ap-south-1.amazonaws.com/service-b"