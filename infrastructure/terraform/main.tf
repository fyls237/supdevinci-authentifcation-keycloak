resource "random_password" "db_password" {
  length = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_string" "db_username" {
  length  = 12
  special = false
  upper   = false
  numeric = true
  lower   = true
}


module "network_keycloak" {
  source = "./modules/network"

  name_prefix = var.name_prefix
  region = var.region
  vpc_cidr = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs = var.public_subnet_cidrs
  azs = var.azs

  tags = var.tags
}

module "storage" {
  source = "./modules/storage"

  name_prefix   = var.name_prefix
  bucket_prefix = var.bucket_prefix

  tags = var.tags
}

module "compute_keycloak" {
  source = "./modules/compute"

  name_prefix    = var.name_prefix
  region         = var.region
  vpc_id         = module.network_keycloak.vpc_id
  subnet_id      = module.network_keycloak.public_subnet_ids[0]
  ami_id         = var.keycloak_ami_id
  instance_type  = var.keycloak_instance_type
  user_data      = var.keycloak_user_data
  allowed_cidrs  = var.allowed_cidrs
  public_key     = var.public_key

  tags = var.tags
  
}

module "db_credentials" {
  source = "./modules/secrets"

  name_prefix        = var.name_prefix
  secret_name_prefix = "${var.name_prefix}-db-credentials"
  description        = "Database credentials for KeyCloak"
  
  secret_json = jsonencode({
    username = local.db_username
    password = "${random_password.db_password.result}"
  })

  tags = var.tags
}

module "db_keycloak" {
  source = "./modules/db"

  name_prefix            = var.name_prefix
  region                 = var.region
  private_subnet_ids     = module.network_keycloak.private_subnet_ids
  vpc_id                 = module.network_keycloak.vpc_id
  ec2_security_group_id  = module.compute_keycloak.security_group_id
  allowed_cidrs          = var.allowed_cidrs # Pas besoin de CIDR, on utilise le Security Group
  db_password            = random_password.db_password.result
  db_username            = local.db_username
  db_name                = var.db_name

  tags = var.tags

  depends_on = [module.db_credentials, module.compute_keycloak]
}