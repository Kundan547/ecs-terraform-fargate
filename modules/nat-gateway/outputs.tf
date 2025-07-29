
# modules/nat-gateway/outputs.tf
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IP addresses associated with the NAT gateways"
  value       = aws_eip.nat[*].public_ip
}