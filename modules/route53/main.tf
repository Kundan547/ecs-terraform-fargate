# modules/route53/main.tf
data "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 0 : 1
  name  = var.domain_name
}

resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name

  tags = {
    Name        = "${var.project_name}-hosted-zone"
    Environment = var.environment
  }
}

locals {
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
}

resource "aws_route53_record" "main" {
  count   = var.create_dns_record ? 1 : 0
  zone_id = local.zone_id
  name    = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  count   = var.create_www_record ? 1 : 0
  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Health check for the main domain
resource "aws_route53_health_check" "main" {
  count                           = var.enable_health_check ? 1 : 0
  fqdn                           = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
  port                           = 443
  type                           = "HTTPS"
  resource_path                  = var.health_check_path
  failure_threshold              = var.health_check_failure_threshold
  request_interval               = var.health_check_request_interval
  cloudwatch_alarm_region        = var.aws_region
  cloudwatch_alarm_name          = "${var.project_name}-health-check-alarm"
  insufficient_data_health_status = "Failure"

  tags = {
    Name        = "${var.project_name}-health-check"
    Environment = var.environment
  }
}

# CloudWatch alarm for health check
resource "aws_cloudwatch_metric_alarm" "health_check" {
  count               = var.enable_health_check ? 1 : 0
  alarm_name          = "${var.project_name}-health-check-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "This metric monitors health check status"
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    HealthCheckId = aws_route53_health_check.main[0].id
  }

  tags = {
    Name        = "${var.project_name}-health-check-alarm"
    Environment = var.environment
  }
}

