# environments/staging/variables.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.1.10.0/24", "10.1.20.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway"
  type        = bool
  default     = true
}

# Domain and SSL Variables
variable "domain_name" {
  description = "Domain name (leave empty to skip Route53 and ACM)"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Subdomain (optional)"
  type        = string
  default     = "staging"
}

variable "subject_alternative_names" {
  description = "Subject alternative names for SSL certificate"
  type        = list(string)
  default     = []
}

variable "create_hosted_zone" {
  description = "Whether to create a new hosted zone"
  type        = bool
  default     = false
}

variable "create_dns_record" {
  description = "Whether to create DNS record"
  type        = bool
  default     = true
}

variable "create_www_record" {
  description = "Whether to create www DNS record"
  type        = bool
  default     = false
}

# ALB Variables
variable "app_port" {
  description = "Port exposed by the docker image"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "alb_enable_deletion_protection" {
  description = "Enable ALB deletion protection"
  type        = bool
  default     = true
}

# ECS Variables
variable "ecs_app_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 2
}

variable "ecs_fargate_cpu" {
  description = "Fargate instance CPU units"
  type        = string
  default     = "512"
}

variable "ecs_fargate_memory" {
  description = "Fargate instance memory"
  type        = string
  default     = "1024"
}

variable "ecs_log_retention_in_days" {
  description = "ECS log retention period"
  type        = number
  default     = 14
}

variable "ecs_environment_variables" {
  description = "Environment variables for ECS tasks"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# RDS Aurora Variables
variable "aurora_engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "aurora_instance_class" {
  description = "Aurora instance class"
  type        = string
  default     = "db.r6g.large"
}

variable "aurora_instance_count" {
  description = "Number of Aurora instances"
  type        = number
  default     = 2
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "database_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
}

variable "aurora_backup_retention_period" {
  description = "Aurora backup retention period"
  type        = number
  default     = 14
}

variable "aurora_backup_window" {
  description = "Aurora backup window"
  type        = string
  default     = "07:00-09:00"
}

variable "aurora_maintenance_window" {
  description = "Aurora maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "aurora_skip_final_snapshot" {
  description = "Skip final snapshot when deleting Aurora cluster"
  type        = bool
  default     = false
}

variable "aurora_deletion_protection" {
  description = "Enable Aurora deletion protection"
  type        = bool
  default     = true
}

variable "aurora_performance_insights_enabled" {
  description = "Enable Aurora Performance Insights"
  type        = bool
  default     = true
}

variable "aurora_monitoring_interval" {
  description = "Aurora enhanced monitoring interval"
  type        = number
  default     = 60
}

# ECR Variables
variable "ecr_image_tag_mutability" {
  description = "ECR image tag mutability"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable ECR scan on push"
  type        = bool
  default     = true
}

variable "ecr_max_image_count" {
  description = "Maximum number of images to keep in ECR"
  type        = number
  default     = 20
}

# S3 Variables
variable "create_s3_bucket" {
  description = "Whether to create S3 bucket for assets"
  type        = bool
  default     = true
}

variable "s3_versioning_enabled" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "s3_block_public_access" {
  description = "Block public access to S3 bucket"
  type        = bool
  default     = true
}

variable "s3_enable_lifecycle" {
  description = "Enable S3 lifecycle management"
  type        = bool
  default     = true
}

variable "s3_expiration_days" {
  description = "S3 object expiration days"
  type        = number
  default     = 365
}

variable "s3_noncurrent_version_expiration_days" {
  description = "S3 noncurrent version expiration days"
  type        = number
  default     = 90
}
variable "database_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}
