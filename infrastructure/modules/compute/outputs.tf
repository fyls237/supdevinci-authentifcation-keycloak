output "instance_id" {
  description = "The ID of the Keycloak EC2 instance"
  value       = aws_instance.keycloak.id
}

output "instance_public_ip" {
  description = "The public IP address of the Keycloak EC2 instance"
  value       = aws_instance.keycloak.public_ip
}

output "security_group_id" {
  description = "The ID of the Keycloak EC2 instance security group"
  value       = aws_security_group.keycloak_sg.id
}

output "security_group_ingress_rules" {
  description = "The ingress rules of the Keycloak EC2 instance security group"
  value       = aws_security_group.keycloak_sg.ingress
}

output "instance_private_ip" {
  description = "The private IP address of the Keycloak EC2 instance"
  value       = aws_instance.keycloak.private_ip
}