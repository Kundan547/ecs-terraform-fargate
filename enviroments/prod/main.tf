# environments/staging/main.tf
locals {
  environment  = "prod"
  project_name = var.project_name

  # Common tags
  common_tags = {
    Environment = local.environment
    Project     = local.project_name
    ManagedBy   = "Terraform"
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name         = local.project_name
  environment          = local.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# NAT Gateway Module
module "nat_gateway" {
  source = "../../modules/nat-gateway"

  project_name            = local.project_name
  environment             = local.environment
  enable_nat_gateway      = var.enable_nat_gateway
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
  internet_gateway_id     = module.vpc.internet_gateway_id
}

# ECR Module
module "ecr" {
  source = "../../modules/ecr"

  project_name         = local.project_name
  environment          = local.environment
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  max_image_count      = var.ecr_max_image_count
}

# Route53 Module (if domain is provided)
module "route53" {
  count  = var.domain_name != "" ? 1 : 0
  source = "../../modules/route53"

  project_name       = local.project_name
  environment        = local.environment
  domain_name        = var.domain_name
  subdomain          = var.subdomain
  create_hosted_zone = var.create_hosted_zone
  create_dns_record  = var.create_dns_record
  create_www_record  = var.create_www_record
  alb_dns_name       = module.alb.alb_dns_name
  alb_zone_id        = module.alb.alb_zone_id
  aws_region         = var.aws_region
}

# ACM Module (if domain is provided)
module "acm" {
  count  = var.domain_name != "" ? 1 : 0
  source = "../../modules/acm"

  project_name              = local.project_name
  environment               = local.environment
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  hosted_zone_id            = var.domain_name != "" ? module.route53[0].zone_id : ""

  depends_on = [module.route53]
}

# ALB Module
module "alb" {
  source = "../../modules/alb"

  project_name               = local.project_name
  environment                = local.environment
  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.public_subnet_ids
  target_port                = var.app_port
  health_check_path          = var.health_check_path
  certificate_arn            = var.domain_name != "" ? module.acm[0].certificate_arn : ""
  enable_deletion_protection = var.alb_enable_deletion_protection
}

# RDS Aurora Module
module "rds_aurora" {
  source = "../../modules/rds-aurora"

  project_name                 = local.project_name
  environment                  = local.environment
  vpc_id                       = module.vpc.vpc_id
  private_subnet_ids           = module.vpc.private_subnet_ids
  ecs_security_group_id        = module.ecs.task_security_group_id
  engine_version               = var.aurora_engine_version
  instance_class               = var.aurora_instance_class
  instance_count               = var.aurora_instance_count
  database_name                = var.database_name
  master_username              = var.database_username
  master_password              = var.database_password
  backup_retention_period      = var.aurora_backup_retention_period
  backup_window                = var.aurora_backup_window
  maintenance_window           = var.aurora_maintenance_window
  skip_final_snapshot          = var.aurora_skip_final_snapshot
  deletion_protection          = var.aurora_deletion_protection
  performance_insights_enabled = var.aurora_performance_insights_enabled
  monitoring_interval          = var.aurora_monitoring_interval
}

# ECS Module
module "ecs" {
  source = "../../modules/ecs"

  project_name          = local.project_name
  environment           = local.environment
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  app_image             = "${module.ecr.repository_url}:latest"
  app_count             = var.ecs_app_count
  fargate_cpu           = var.ecs_fargate_cpu
  fargate_memory        = var.ecs_fargate_memory
  container_port        = var.app_port
  aws_region            = var.aws_region
  log_retention_in_days = var.ecs_log_retention_in_days
  environment_variables = var.ecs_environment_variables

  depends_on = [module.nat_gateway]
}

# S3 Bucket for application assets (optional)
module "s3_assets" {
  count  = var.create_s3_bucket ? 1 : 0
  source = "../../modules/s3"

  bucket_name                        = "${local.project_name}-${local.environment}-assets"
  environment                        = local.environment
  versioning_enabled                 = var.s3_versioning_enabled
  block_public_access                = var.s3_block_public_access
  enable_lifecycle                   = var.s3_enable_lifecycle
  expiration_days                    = var.s3_expiration_days
  noncurrent_version_expiration_days = var.s3_noncurrent_version_expiration_days
}

