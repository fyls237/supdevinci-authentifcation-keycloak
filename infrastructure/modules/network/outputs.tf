# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.vpc.arn
}

# Internet Gateway Outputs
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.internet_gateway.id
}

# NAT Gateway Outputs
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.igw.id
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "elastic_ip_id" {
  description = "The ID of the Elastic IP used by the NAT Gateway"
  value       = aws_eip.nat.id
}

# Public Subnets Outputs
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_azs" {
  description = "List of Availability Zones of public subnets"
  value       = aws_subnet.public[*].availability_zone
}

# Private Subnets Outputs
output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_azs" {
  description = "List of Availability Zones of private subnets"
  value       = aws_subnet.private[*].availability_zone
}

# Route Tables Outputs
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

# Availability Zones Outputs
output "availability_zones" {
  description = "List of Availability Zones used"
  value       = var.azs
}


output "network_summary" {
  description = "Summary of the network configuration"
  value = {
    vpc_id             = aws_vpc.vpc.id
    vpc_cidr           = aws_vpc.vpc.cidr_block
    public_subnets     = aws_subnet.public[*].id
    private_subnets    = aws_subnet.private[*].id
    nat_gateway_ip     = aws_eip.nat.public_ip
    availability_zones = var.azs
  }
}
