# Network Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value = module.network_keycloak.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = module.network_keycloak.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network_keycloak.private_subnet_ids
}

# Compute Outputs
output "keycloak_instance_id" {
  description = "Keycloak EC2 instance ID"
  value       = module.compute_keycloak.instance_id
}

output "keycloak_public_ip" {
  description = "Keycloak EC2 public IP"
  value       = module.compute_keycloak.instance_public_ip
}

output "keycloak_private_ip" {
  description = "Keycloak EC2 private IP"
  value = module.compute_keycloak.instance_private_ip
}


# Database Outputs
output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value = module.db_keycloak.rds_endpoint
}

output "db_name" {
  description = "The name of the database"
  value       = module.db_keycloak.db_name
}

output "db_port" {
  description = "The port of the database"
  value       = module.db_keycloak.db_port
}

# Storage Outputs
output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.storage.bucket_name
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.storage.bucket_arn
}


# Secrets Outputs
output "db_credentials_secret_arn" {
  description = "The ARN of the database credentials secret"
  value = module.db_credentials.secret_arn
}

output "db_credentials_secret_name" {
  description = "The name of the database credentials secret"
  value = module.db_credentials.secret_name
}

