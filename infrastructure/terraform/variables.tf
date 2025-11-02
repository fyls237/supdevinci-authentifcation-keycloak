variable "region" {
  description = "AWS region"
  type        = string  
}

variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

# Storage Configuration
variable "bucket_prefix" {
    description = "Prefix for the S3 bucket name"
    type        = string
}

# Compute Configuration
variable "keycloak_ami_id" {
  description = "AMI ID for the Keycloak EC2 instance"
  type        = string
}

variable "keycloak_instance_type" {
  description = "Instance type for the Keycloak EC2 instance"
  type        = string
}

variable "keycloak_user_data" {
  description = "User data for the Keycloak EC2 instance"
  type        = string
  default     = ""
}

variable "allowed_cidrs" {
  description = "List of allowed CIDR blocks for the Keycloak EC2 instance"
  type        = list(string)
}

variable "db_name" {
  description = "Data base name for keycloak"
  type =  string
  default = "keycloakdb"
}


variable "profile" {
  description = "Profile name to use for AWS provider"
  type        = string
}

variable "public_key" {
  description = "Public key pair for the EC2 instance"
  type        = string
}