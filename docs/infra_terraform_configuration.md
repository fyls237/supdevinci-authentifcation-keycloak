# Terraform Infrastructure Configuration

## Overview
The Terraform configuration provisions AWS infrastructure for Keycloak including network, storage, compute, database and secrets.

## Prerequisites
- Terraform >= 0.13
- AWS CLI configured
- Required versions in [`versions.tf`](infrastructure/terraform/versions.tf:1)

## Directory Structure
```
infrastructure/terraform/
├── [`versions.tf`](infrastructure/terraform/versions.tf:1)
├── [`local.tf`](infrastructure/terraform/local.tf:1)
├── [`variables.tf`](infrastructure/terraform/variables.tf:1)
├── [`main.tf`](infrastructure/terraform/main.tf:1)
├── [`outputs.tf`](infrastructure/terraform/outputs.tf:1)
└── modules/
```

## versions.tf
Defines required providers:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.19"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}
```

## local.tf
Defines local values using random resources:

```hcl
locals {
  db_username = "keycloak_${random_string.db_username.result}"
}
```

## variables.tf
List input variables:

- `region` (string): AWS region  
- `profile` (string): AWS profile  
- `tags` (map(string)): tags for resources  
- `name_prefix` (string): prefix for resource names  
- `vpc_cidr` (string): VPC CIDR block  
- `public_subnet_cidrs` (list(string)): public subnets  
- `private_subnet_cidrs` (list(string)): private subnets  
- `azs` (list(string)): availability zones  
- `bucket_prefix` (string): S3 bucket prefix  
- `keycloak_ami_id` (string): AMI ID  
- `keycloak_instance_type` (string): EC2 instance type  
- `keycloak_user_data` (string, default ""): User-data for EC2  
- `allowed_cidrs` (list(string)): allowed CIDR blocks  
- `db_name` (string, default "keycloakdb"): database name  
- `public_key` (string): SSH public key for EC2  

## main.tf
Defines dynamic resources and modules:

### Random Resources
```hcl
resource "random_password" "db_password" {
  length             = 16
  special            = true
  override_special   = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_string" "db_username" {
  length  = 12
  special = false
  upper   = false
  numeric = true
  lower   = true
}
```

### Modules

#### Network ([`modules/network`](infrastructure/terraform/modules/network/main.tf:1))
- Source: `./modules/network`  
- Configures VPC and subnets.  
- Parameters:  
  - `name_prefix`  
  - `region`  
  - `vpc_cidr`  
  - `private_subnet_cidrs`  
  - `public_subnet_cidrs`  
  - `azs`  
  - `tags`

```hcl
module "network_keycloak" {
  source                 = "./modules/network"
  name_prefix            = var.name_prefix
  region                 = var.region
  vpc_cidr               = var.vpc_cidr
  private_subnet_cidrs   = var.private_subnet_cidrs
  public_subnet_cidrs    = var.public_subnet_cidrs
  azs                    = var.azs
  tags                   = var.tags
}
```

#### Storage ([`modules/storage`](infrastructure/terraform/modules/storage/README.md:1))
- Source: `./modules/storage`  
- Creates S3 bucket.  
- Parameters: `name_prefix`, `bucket_prefix`, `tags`

```hcl
module "storage" {
  source        = "./modules/storage"
  name_prefix   = var.name_prefix
  bucket_prefix = var.bucket_prefix
  tags          = var.tags
}
```

#### Compute ([`modules/compute`](infrastructure/terraform/modules/compute/main.tf:1))
- Source: `./modules/compute`  
- Launches Keycloak EC2 instance.  
- Parameters:  
  - `name_prefix`  
  - `region`  
  - `vpc_id`  
  - `subnet_id`  
  - `ami_id`  
  - `instance_type`  
  - `user_data`  
  - `allowed_cidrs`  
  - `public_key`  
  - `tags`

```hcl
module "compute_keycloak" {
  source          = "./modules/compute"
  name_prefix     = var.name_prefix
  region          = var.region
  vpc_id          = module.network_keycloak.vpc_id
  subnet_id       = module.network_keycloak.public_subnet_ids[0]
  ami_id          = var.keycloak_ami_id
  instance_type   = var.keycloak_instance_type
  user_data       = var.keycloak_user_data
  allowed_cidrs   = var.allowed_cidrs
  public_key      = var.public_key
  tags            = var.tags
}
```

#### Secrets ([`modules/secrets`](infrastructure/terraform/modules/secrets/README.md:1))
- Source: `./modules/secrets`  
- Stores DB credentials in Secrets Manager.  
- Parameters:  
  - `name_prefix`  
  - `secret_name_prefix`  
  - `description`  
  - `secret_json`  
  - `tags`

```hcl
module "db_credentials" {
  source             = "./modules/secrets"
  name_prefix        = var.name_prefix
  secret_name_prefix = "${var.name_prefix}-db-credentials"
  description        = "Database credentials for KeyCloak"
  secret_json        = jsonencode({
    username = local.db_username
    password = random_password.db_password.result
  })
  tags               = var.tags
}
```

#### Database ([`modules/db`](infrastructure/terraform/modules/db/main.tf:1))
- Source: `./modules/db`  
- Creates a database resource (e.g., RDS) for Keycloak.  
- Parameters:  
  - `name_prefix`  
  - `region`  
  - `private_subnet_ids`  
  - `vpc_id`  
  - `ec2_security_group_id`  
  - `allowed_cidrs`  
  - `db_password`  
  - `db_username`  
  - `db_name`  
  - `tags`  
  - `depends_on`

```hcl
module "db_keycloak" {
  source                 = "./modules/db"
  name_prefix            = var.name_prefix
  region                 = var.region
  private_subnet_ids     = module.network_keycloak.private_subnet_ids
  vpc_id                 = module.network_keycloak.vpc_id
  ec2_security_group_id  = module.compute_keycloak.security_group_id
  allowed_cidrs          = var.allowed_cidrs
  db_password            = random_password.db_password.result
  db_username            = local.db_username
  db_name                = var.db_name
  tags                   = var.tags
  depends_on             = [module.db_credentials, module.compute_keycloak]
}
```

## outputs.tf
Defines outputs for integration and reference:

- `vpc_id`  
- `public_subnet_ids`  
- `private_subnet_ids`  
- `keycloak_instance_id`  
- `keycloak_public_ip`  
- `keycloak_private_ip`  
- `rds_endpoint`  
- `db_name`  
- `db_port`  
- `s3_bucket_name`  
- `s3_bucket_arn`  
- `db_credentials_secret_arn`  
- `db_credentials_secret_name`

```hcl
output "vpc_id" { ... }
...
output "db_credentials_secret_name" { ... }