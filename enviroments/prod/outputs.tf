# environments/prod/outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.alb.alb_zone_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.rds_aurora.cluster_endpoint
  sensitive   = true
}

output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint"
  value       = module.rds_aurora.reader_endpoint
  sensitive   = true
}

output "domain_name" {
  description = "Domain name (if configured)"
  value       = var.domain_name != "" ? (var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name) : module.alb.alb_dns_name
}

output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = var.domain_name != "" ? module.acm[0].certificate_arn : null
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket (if created)"
  value       = var.create_s3_bucket ? module.s3_assets[0].bucket_id : null
}

output "nat_gateway_public_ips" {
  description = "Public IPs of NAT Gateways"
  value       = module.nat_gateway.nat_gateway_public_ips
}
  