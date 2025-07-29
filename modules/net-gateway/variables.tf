# modules/nat-gateway/variables.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT Gateway"
  type        = bool
  default     = true
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of private route table IDs"
  type        = list(string)
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type        = string
}
