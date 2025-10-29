# Low-Level Design (LLD)

```mermaid
graph TB
  subgraph AWS_Cloud
    VPC[VPC]
    IGW[Internet Gateway]
    VPC --> IGW

    PubSubnet1[Public Subnet 1]
    PubSubnet2[Public Subnet 2]
    VPC --> PubSubnet1
    VPC --> PubSubnet2

    NAT[NAT Gateway]
    PubSubnet1 --> NAT

    PrivSubnet1[Private Subnet 1]
    PrivSubnet2[Private Subnet 2]
    NAT --> PrivSubnet1
    NAT --> PrivSubnet2

    EC2[EC2 Instance – Docker + Keycloak]
    PubSubnet1 --> EC2

    RDS[RDS PostgreSQL Multi-AZ Backups]
    EC2 --> RDS

    S3[S3 Bucket – Keycloak backups]
    EC2 --> S3

    SM[Secrets Manager – DB and client secrets]
    EC2 --> SM

    subgraph Security_Group
      SG["Keycloak SG - allow ports 8080,22"]
    end
    EC2 -- SG --> SG
  end

  subgraph External_IdPs
    AzureAD[Azure Entra ID OIDC]
    IAMCenter["AWS IAM Identity Center - SAML or OIDC"]
    OtherIdP[Other IdP - Okta and Google]
  end

  Users[Enterprise Users]
  Users --> AzureAD
  Users --> IAMCenter
  Users --> OtherIdP

  AzureAD --> EC2
  IAMCenter --> EC2
  OtherIdP --> EC2