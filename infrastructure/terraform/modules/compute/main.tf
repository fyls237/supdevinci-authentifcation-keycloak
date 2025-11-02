data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "keycloak_sg" {
  name_prefix = "${var.name_prefix}-keycloak-sg-"
  description = "Security group for Keycloak EC2 instance"
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-keycloak-sg"
    }
  )

  ingress {
    description = "Keycloak HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
  
  ingress {
    description = "Keycloak HTTPS"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  ingress {
    description = "Keycloak Admin Console"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.name_prefix}-keypair"
  public_key = "${var.public_key}"
}

resource "aws_instance" "keycloak" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.keycloak_sg.id]
  user_data              = var.user_data
  key_name               = aws_key_pair.key_pair.key_name
  
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
    
    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-keycloak-root-volume"
      }
    )
  }
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.name_prefix}-keycloak-ec2"
      Application = "Keycloak"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}