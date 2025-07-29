# modules/nat-gateway/main.tf
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? length(var.public_subnet_ids) : 0
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip-${count.index + 1}"
    Environment = var.environment
  }

  depends_on = [var.internet_gateway_id]
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.public_subnet_ids) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]

  tags = {
    Name        = "${var.project_name}-nat-gateway-${count.index + 1}"
    Environment = var.environment
  }

  depends_on = [var.internet_gateway_id]
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? length(var.private_route_table_ids) : 0

  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

