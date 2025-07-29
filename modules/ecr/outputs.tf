# modules/ecr/outputs.tf
output "repository_arn" {
  description = "Full ARN of the repository"
  value       = aws_ecr_repository.app.arn
}

output "repository_name" {
  description = "Name of the repository"
  value       = aws_ecr_repository.app.name
}

output "repository_url" {
  description = "URL of the repository"
  value       = aws_ecr_repository.app.repository_url
}

output "registry_id" {
  description = "Registry ID where the repository was created"
  value       = aws_ecr_repository.app.registry_id
}