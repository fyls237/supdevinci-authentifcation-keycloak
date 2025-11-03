# supdevinci-authentifcation-keycloak

Federate authentication multicloud AWS and Azure with Keycloak.

## Table of Contents

- [Architecture Overview](docs/ARCHITECTURE.md) 📊 **Nouveau : Schéma d'architecture complet**
- [`docs/architecture_hld.md`](docs/architecture_hld.md)
- [`docs/architecture_lld.md`](docs/architecture_lld.md)
- Infrastructure (#infrastructure)
  - [`docs/infra_terraform_configuration.md`](docs/infra_terraform_configuration.md)
  - [`docs/infra_ansible_configuration.md`](docs/infra_ansible_configuration.md)
- [Deployment Success Report](DEPLOYMENT_SUCCESS.md) ✅
- [Troubleshooting Guide](TROUBLESHOOTING.md) 🔧

## Infrastructure

### Terraform Configuration

Detailed information can be found in [`docs/infra_terraform_configuration.md`](docs/infra_terraform_configuration.md:1).

### Ansible Configuration

Detailed information can be found in [`docs/infra_ansible_configuration.md`](docs/infra_ansible_configuration.md:1).

## Prerequisites

- Terraform >= 0.13
- Ansible >= 2.9
- AWS CLI configured

## Usage

1. Deploy Terraform:
   ```bash
   cd infrastructure/terraform
   terraform init
   terraform apply -auto-approve
   ```

2. Deploy Ansible:
   ```bash
   cd infrastructure/ansible
   ansible-playbook -i inventory/aws_ec2.yml playbooks/site.yml
