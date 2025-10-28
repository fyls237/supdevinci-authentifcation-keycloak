provider "aws" {
  region = var.region
}

resource "aws_security_group" "keycloak_sg" {
  name        = "${var.name_prefix}-keycloak-sg"
  description = "Security group for Keycloak EC2 instance"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "keycloak" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.keycloak_sg.id]
  user_data              = var.user_data
  tags                   = merge(var.tags, { Name = "${var.name_prefix}-keycloak" })
}