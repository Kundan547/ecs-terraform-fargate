# modules/route53/outputs.tf
output "zone_id" {
  description = "Zone ID of the hosted zone"
  value       = local.zone_id
}

output "name_servers" {
  description = "Name servers of the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : null
}

output "fqdn" {
  description = "FQDN of the main record"
  value       = var.create_dns_record ? aws_route53_record.main[0].fqdn : null
}

output "health_check_id" {
  description = "ID of the health check"
  value       = var.enable_health_check ? aws_route53_health_check.main[0].id : null
}