output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value       = aws_db_subnet_group.db.name
}

output "db_instance_id" {
  description = "The ID of the DB instance"
  value       = aws_db_instance.db.id
}

output "db_instance_arn" {
  description = "The ARN of the DB instance"
  value       = aws_db_instance.db.arn
}

output "db_instance_address" {
  description = "The address of the DB instance"
  value       = aws_db_instance.db.address
}

output "db_instance_port" {
  description = "The port of the DB instance"
  value       = aws_db_instance.db.port
  sensitive   = true
}

output "db_instance_username" {
  description = "The root username of the DB instance"
  value       = aws_db_instance.db.username
  sensitive   = true
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.db.endpoint
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.db.db_name
}

output "db_port" {
  description = "The port of the database"
  value       = aws_db_instance.db.port
}
