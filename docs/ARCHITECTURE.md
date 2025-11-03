# Architecture Keycloak - Authentification Multicloud

## 🏗️ Vue d'ensemble

Ce document présente l'architecture complète de la solution d'authentification Keycloak déployée sur AWS avec intégration multicloud (AWS et Azure).

## 📊 Schéma d'Architecture

> **Note**: Pour voir le schéma interactif, consultez le [fichier diagrams.net](https://drive.google.com/file/d/10NRpUFvxpPl_byZxovBp_Gv2Qig_JEIw/view?usp=sharing)

## 🔧 Composants de l'Architecture

### 1. Couche Réseau (VPC)

```
VPC: 10.0.0.0/16 (eu-north-1)
├── Public Subnets
│   ├── 10.0.1.0/24 (eu-north-1a)
│   └── 10.0.3.0/24 (eu-north-1b)
└── Private Subnets
    ├── 10.0.11.0/24 (eu-north-1a)
    └── 10.0.13.0/24 (eu-north-1b)
```

**Composants** :
- Internet Gateway pour l'accès public
- NAT Gateway pour la sortie des instances privées
- Route Tables pour le routage

### 2. Couche Compute (EC2)

```
Instance Keycloak
├── Type: t3.medium
├── OS: Amazon Linux 2023
├── Public IP: 13.53.127.230
├── Private IP: 10.0.1.38
└── Security Group: sg-0529a09ff54ed67bc
    ├── Port 22 (SSH)
    ├── Port 8080 (HTTP)
    ├── Port 8443 (HTTPS)
    └── Port 9000 (Management)
```

**Caractéristiques** :
- Volume root: 30 GB GP3 (chiffré)
- Keycloak 26.4.0
- Java 17 (Amazon Corretto)
- Certificat SSL auto-signé

### 3. Couche Base de Données (RDS)

```
RDS PostgreSQL
├── Engine: PostgreSQL 14.19
├── Instance: db.t3.micro
├── Database: keycloakdb
├── Storage: 20 GB GP3
├── Multi-AZ: Non (à activer en production)
└── Security Group: sg-07c476e0701cddc72
    └── Port 5432 (depuis EC2 SG)
```

**Configuration** :
- Backup automatique: 7 jours
- Subnet Group: Private subnets
- Encryption at rest: Activé
- Connection pooling: 5-20 connexions

### 4. Couche Stockage (S3)

```
S3 Bucket
├── Name: keycloak-prod-s3-bucket-*
├── Versioning: Désactivé (à activer en production)
├── Encryption: AES256
└── Usage:
    ├── Backups Keycloak
    ├── Logs
    └── Exports/Imports
```

### 5. Couche Secrets (Secrets Manager)

```
AWS Secrets Manager
├── Secret: keycloak-prod-db-credentials
├── Rotation: Désactivée (à activer en production)
└── Contenu:
    ├── username
    ├── password
    └── engine (postgres)
```

## 🔐 Flux de Sécurité

### Flux d'Authentification

```
┌─────────────┐
│   Utilisateur│
└──────┬──────┘
       │ HTTPS (8443)
       ▼
┌─────────────────────┐
│  Internet Gateway   │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  Security Group     │
│  (sg-...67bc)       │
│  ✓ Port 8443        │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  EC2 Keycloak       │
│  13.53.127.230      │
│                     │
│  ┌───────────────┐  │
│  │ Keycloak      │  │
│  │ 26.4.0        │  │
│  └───────┬───────┘  │
└──────────┼──────────┘
           │ JDBC (5432)
           ▼
    ┌─────────────────┐
    │ Security Group  │
    │ (sg-...dc72)    │
    │ ✓ Port 5432     │
    └─────┬───────────┘
          │
          ▼
    ┌─────────────────┐
    │ RDS PostgreSQL  │
    │ 10.0.11.x       │
    │ (Private)       │
    └─────────────────┘
```

### Flux de Données

```
Keycloak ─┬─[HTTPS]──> Utilisateurs (authentification)
          │
          ├─[JDBC]───> RDS (stockage données)
          │
          ├─[AWS API]─> Secrets Manager (credentials)
          │
          ├─[S3 API]──> S3 (backups/logs)
          │
          └─[HTTPS]───> AWS IAM Identity Center (fédération)
```

## 🌐 Intégration Multicloud

### AWS Identity Center

```
AWS Identity Center
├── Permission Sets
│   ├── Keycloak-Admin-Access
│   ├── Keycloak-User-Access
│   └── Keycloak-ReadOnly-Access
├── Users (SCIM sync depuis Keycloak)
└── Groups
    ├── Administrators
    ├── Developers
    └── Users
```

### Azure Entra ID (anciennement Azure AD)

```
Azure Entra ID
├── Enterprise Application
│   └── Keycloak SAML/OIDC App
├── Users (fédérés depuis Keycloak)
└── Groups
    ├── AAD-Keycloak-Admins
    ├── AAD-Keycloak-Users
    └── AAD-Keycloak-ReadOnly
```

**Protocoles d'intégration** :
- SAML 2.0 pour Azure Entra ID
- OIDC pour AWS Identity Center
- SCIM pour la synchronisation des utilisateurs

## 📊 Tableau de Flux Réseau

| Source | Destination | Port | Protocole | Description |
|--------|-------------|------|-----------|-------------|
| Internet | EC2 | 22 | TCP | SSH Administration |
| Internet | EC2 | 8080 | TCP | HTTP (redirect vers HTTPS) |
| Internet | EC2 | 8443 | TCP | HTTPS Keycloak |
| Internet | EC2 | 9000 | TCP | Management Interface |
| EC2 | RDS | 5432 | TCP | PostgreSQL Database |
| EC2 | Internet | 443 | TCP | AWS API, Updates |
| EC2 | Secrets Manager | 443 | TCP | Retrieve DB credentials |
| EC2 | S3 | 443 | TCP | Backup/Logs storage |

## 🔄 Haute Disponibilité (Roadmap)

### Configuration Actuelle
- ❌ Single EC2 instance
- ❌ Single AZ RDS
- ❌ Pas de Load Balancer

### Configuration Production Recommandée

```
                    ┌──────────────────┐
                    │  Route 53 DNS    │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │  Application LB  │
                    │  (Multi-AZ)      │
                    └────┬────────┬────┘
                         │        │
              ┌──────────▼──┐  ┌──▼──────────┐
              │ Keycloak-1  │  │ Keycloak-2  │
              │ (AZ-A)      │  │ (AZ-B)      │
              └──────┬──────┘  └──┬──────────┘
                     │            │
              ┌──────▼────────────▼─────┐
              │  RDS PostgreSQL        │
              │  Multi-AZ              │
              │  (Primary + Standby)   │
              └────────────────────────┘
```

**Améliorations à implémenter** :
1. Auto Scaling Group pour EC2
2. Application Load Balancer
3. Multi-AZ RDS avec réplicas en lecture
4. ElastiCache Redis pour le cache des sessions
5. CloudWatch Alarms
6. AWS Backup pour RDS et S3

## 🛡️ Sécurité

### Chiffrement

| Composant | Chiffrement au repos | Chiffrement en transit |
|-----------|---------------------|------------------------|
| EC2 EBS | ✅ KMS | N/A |
| RDS | ✅ KMS | ✅ TLS |
| S3 | ✅ AES256 | ✅ TLS |
| Secrets Manager | ✅ KMS | ✅ TLS |
| Keycloak | ✅ (DB) | ✅ HTTPS/TLS |

### Conformité

- **RGPD** : Gestion des données personnelles dans Keycloak
- **PCI-DSS** : Chiffrement des données sensibles
- **SOC 2** : Logs d'audit et traçabilité
- **ISO 27001** : Gestion des accès et secrets

## 📈 Monitoring et Observabilité

### Métriques Actuelles

```
Keycloak Metrics (Port 9000)
├── JVM Metrics
│   ├── Heap Memory
│   ├── Non-Heap Memory
│   └── Thread Count
├── HTTP Metrics
│   ├── Request Count
│   ├── Request Duration
│   └── Error Rate
└── Database Metrics
    ├── Connection Pool
    ├── Active Connections
    └── Query Performance
```

### CloudWatch (à implémenter)

```
CloudWatch Dashboards
├── Infrastructure Health
│   ├── EC2 CPU/Memory
│   ├── RDS Connections
│   └── Network Traffic
├── Application Health
│   ├── Keycloak Availability
│   ├── Login Success Rate
│   └── Error Rates
└── Alarms
    ├── High CPU (>80%)
    ├── Low Disk Space (<20%)
    ├── RDS Connection Errors
    └── HTTP 5xx Errors
```

## 🔗 Liens et Références

### Accès

- **Keycloak Web UI** : https://13.53.127.230:8443/
- **Admin Console** : https://13.53.127.230:8443/admin
- **Health Check** : https://13.53.127.230:9000/health
- **Metrics** : https://13.53.127.230:9000/metrics

### Documentation

- [High-Level Design (HLD)](architecture_hld.md)
- [Low-Level Design (LLD)](architecture_lld.md)
- [Terraform Configuration](infra_terraform_configuration.md)
- [Ansible Configuration](infra_ansible_configuration.md)
- [Deployment Guide](../DEPLOYMENT_SUCCESS.md)
- [Troubleshooting Guide](../TROUBLESHOOTING.md)

### Ressources Externes

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 📝 Notes de Déploiement

### Version Actuelle
- **Date** : 2025-11-03
- **Environnement** : Production
- **Keycloak** : 26.4.0
- **PostgreSQL** : 14.19
- **Terraform** : >= 1.0
- **Ansible** : >= 2.9

### Prochaines Étapes
1. ✅ Déploiement infrastructure Terraform
2. ✅ Configuration Keycloak via Ansible
3. ✅ Certificat SSL auto-signé
4. ⏳ Migration vers Let's Encrypt
5. ⏳ Mise en place ALB + Auto Scaling
6. ⏳ Configuration Multi-AZ RDS
7. ⏳ Intégration CloudWatch
8. ⏳ Configuration SCIM pour AWS/Azure
