resource "aws_ecr_repository" "service_a" {
  name = "service-a"
  image_scanning_configuration { scan_on_push = true }
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "service_b" {
  name = "service-b"
  image_scanning_configuration { scan_on_push = true }
  image_tag_mutability = "MUTABLE"
}

output "ecr_repo_service_a" {
  value = aws_ecr_repository.service_a.repository_url
}

output "ecr_repo_service_b" {
  value = aws_ecr_repository.service_b.repository_url
}
