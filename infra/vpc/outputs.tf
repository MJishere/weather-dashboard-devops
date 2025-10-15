# VPC ID
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

# Public Subnets IDs
output "public_subnet_ids" {
  value       = aws_subnet.public_subnets[*].id
  description = "List of public subnet IDs"
}

# Private Subnets IDs
output "private_subnet_ids" {
  value       = aws_subnet.private_subnets[*].id
  description = "List of private subnet IDs"
}

# Internet Gateway ID
output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "The ID of the Internet Gateway"
}

# NAT Gateway ID
output "nat_gateway_id" {
  value       = aws_nat_gateway.ngw.id
  description = "The ID of the NAT Gateway"
}

# Public Route Table ID
output "public_route_table_id" {
  value       = aws_route_table.public_route_table.id
  description = "The ID of the public route table"
}

# Private Route Table ID
output "private_route_table_id" {
  value       = aws_route_table.private_route_table.id
  description = "The ID of the private route table"
}
