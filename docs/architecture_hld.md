# High-Level Architecture (HLD)

```mermaid
graph LR
  subgraph AWS Cloud
    direction TB
    subgraph VPC
      direction LR
      IGW[Internet Gateway]
      PublicSubnet[Public Subnet]
      PrivateSubnet[Private Subnet]
      IGW --> PublicSubnet
      PublicSubnet --> EC2[Keycloak EC2 Instance]
      EC2 --> PrivateSubnet
      PrivateSubnet --> RDS[(PostgreSQL RDS)]
      EC2 --> S3[(S3 Bucket)]
      EC2 --> SM[(Secrets Manager)]
    end
  end

  subgraph External IdPs
    direction TB
    AzureAD[Azure Entra ID]
    IAMCenter[AWS IAM Identity Center]
    OtherIdP[Other IdP]
  end

  Users[Enterprise Users] --> IGW
  Users --> AzureAD
  Users --> IAMCenter
  Users --> OtherIdP
  AzureAD --> EC2
  IAMCenter --> EC2
  OtherIdP --> EC2
  EC2 --> Users