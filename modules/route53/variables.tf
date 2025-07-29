# modules/route53/variables.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomain (optional)"
  type        = string
  default     = ""
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
  default     = true
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB"
  type        = string
}

variable "enable_health_check" {
  description = "Enable Route53 health check"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/"
}

variable "health_check_failure_threshold" {
  description = "Health check failure threshold"
  type        = number
  default     = 3
}

variable "health_check_request_interval" {
  description = "Health check request interval"
  type        = number
  default     = 30
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for health check alarms"
  type        = string
  default     = ""
}

