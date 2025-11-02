# Secrets Module (AWS Secrets Manager)

Module Terraform pour créer et gérer des secrets dans AWS Secrets Manager.

## Fonctionnalités

- ✅ Stockage sécurisé de secrets
- ✅ Chiffrement avec KMS
- ✅ Rotation automatique optionnelle
- ✅ Récupération après suppression
- ✅ Support JSON pour secrets complexes

## Utilisation

### Exemple basique (secret simple)

```hcl
module "db_password" {
  source = "./modules/secrets"

  name_prefix        = "keycloak"
  secret_name_prefix = "keycloak-db-password-"
  description        = "Database password for KeyCloak"
  
  secret_string = "MySecurePassword123!"

  tags = {
    Environment = "production"
    Project     = "KeyCloak"
  }
}
```

### Exemple avec JSON (multiple valeurs)

```hcl
module "db_credentials" {
  source = "./modules/secrets"

  name_prefix        = "keycloak"
  secret_name_prefix = "keycloak-db-creds-"
  description        = "Database credentials for KeyCloak"
  
  secret_json = jsonencode({
    username = "keycloak_admin"
    password = "MySecurePassword123!"
    host     = "db.example.com"
    port     = 5432
    database = "keycloak"
  })

  tags = {
    Environment = "production"
    Project     = "KeyCloak"
  }
}
```

### Exemple avec chiffrement KMS

```hcl
module "api_keys" {
  source = "./modules/secrets"

  name_prefix        = "keycloak"
  secret_name_prefix = "keycloak-api-keys-"
  description        = "API keys for external services"
  
  secret_json = jsonencode({
    github_token = "ghp_xxxxxxxxxxxx"
    aws_key      = "AKIAIOSFODNN7EXAMPLE"
  })

  kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "production"
    Project     = "KeyCloak"
  }
}
```

### Exemple avec rotation automatique

```hcl
module "rotated_password" {
  source = "./modules/secrets"

  name_prefix        = "keycloak"
  secret_name_prefix = "keycloak-rotating-password-"
  description        = "Password with automatic rotation"
  
  secret_string = "InitialPassword123!"

  enable_rotation     = true
  rotation_lambda_arn = aws_lambda_function.rotate_secret.arn
  rotation_days       = 30

  tags = {
    Environment = "production"
    Project     = "KeyCloak"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | string | - | yes |
| secret_name_prefix | Prefix for the secret name | string | - | yes |
| description | Description of the secret | string | "" | no |
| secret_string | Secret value as string | string | "" | no |
| secret_json | Secret value as JSON | string | "" | no |
| kms_key_id | KMS key ID for encryption | string | null | no |
| recovery_window_in_days | Recovery window in days | number | 30 | no |
| enable_rotation | Enable automatic rotation | bool | false | no |
| rotation_lambda_arn | Lambda ARN for rotation | string | "" | no |
| rotation_days | Days between rotations | number | 30 | no |

## Outputs

| Name | Description |
|------|-------------|
| secret_id | The ID of the secret |
| secret_arn | The ARN of the secret |
| secret_name | The name of the secret |
| secret_version_id | The version ID of the secret |

## Récupération des secrets

### Dans Terraform

```hcl
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = module.db_password.secret_id
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)
}
```

### Avec AWS CLI

```bash
# Secret simple
aws secretsmanager get-secret-value --secret-id <secret_name> --query SecretString --output text

# Secret JSON
aws secretsmanager get-secret-value --secret-id <secret_name> --query SecretString --output text | jq -r .password
```

### Dans une application

```python
import boto3
import json

client = boto3.client('secretsmanager')

# Récupérer le secret
response = client.get_secret_value(SecretId='secret_name')
secret = json.loads(response['SecretString'])

print(secret['password'])
```

## Sécurité

Ce module implémente les meilleures pratiques de sécurité :
- Chiffrement par défaut
- Support KMS pour chiffrement avancé
- Rotation automatique optionnelle
- Fenêtre de récupération configurable
- Variables sensibles marquées comme `sensitive`
