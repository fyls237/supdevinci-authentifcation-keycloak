# Storage Module (S3)

Module Terraform pour créer et gérer un bucket S3 avec les meilleures pratiques de sécurité.

## Fonctionnalités

- ✅ Bucket S3 avec chiffrement par défaut
- ✅ Versioning configurable
- ✅ Blocage des accès publics
- ✅ Règles de cycle de vie optionnelles
- ✅ Logging d'accès optionnel
- ✅ Support KMS pour le chiffrement

## Utilisation

### Exemple basique

```hcl
module "storage" {
  source = "./modules/storage"

  name_prefix   = "keycloak"
  bucket_prefix = "keycloak-data-"

  tags = {
    Environment = "production"
    Project     = "KeyCloak"
  }
}
```

### Exemple avec versioning et lifecycle

```hcl
module "storage" {
  source = "./modules/storage"

  name_prefix   = "keycloak"
  bucket_prefix = "keycloak-backups-"

  enable_versioning      = true
  enable_lifecycle_rules = true

  transition_to_ia_days      = 30
  transition_to_glacier_days = 90
  noncurrent_version_expiration_days = 180

  tags = {
    Environment = "production"
    Project     = "KeyCloak"
  }
}
```

### Exemple avec chiffrement KMS

```hcl
module "storage" {
  source = "./modules/storage"

  name_prefix   = "keycloak"
  bucket_prefix = "keycloak-secure-"

  sse_algorithm     = "aws:kms"
  kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

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
| bucket_prefix | Prefix for the S3 bucket name | string | - | yes |
| enable_versioning | Enable versioning | bool | true | no |
| sse_algorithm | Encryption algorithm (AES256 or aws:kms) | string | AES256 | no |
| block_public_acls | Block public ACLs | bool | true | no |
| enable_lifecycle_rules | Enable lifecycle rules | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The ID of the S3 bucket |
| bucket_arn | The ARN of the S3 bucket |
| bucket_name | The name of the S3 bucket |
| bucket_domain_name | The bucket domain name |

## Sécurité

Ce module implémente les meilleures pratiques de sécurité :
- Chiffrement activé par défaut
- Blocage des accès publics
- Versioning recommandé
- Support KMS pour le chiffrement avancé
