# Ansible Infrastructure Configuration

## Overview
The Ansible configuration automates the deployment and configuration of Keycloak servers on AWS using dynamic inventory and a custom Keycloak role.

## Prerequisites
- Ansible >= 2.9  
- AWS CLI with a configured profile (see [`aws_ec2.yml`](infrastructure/ansible/inventory/aws_ec2.yml:1))  
- Python dependencies: `boto`, `botocore` (`pip install boto boto3`)  
- Ansible collections: `amazon.aws` (`ansible-galaxy collection install amazon.aws`)

## Directory Structure
```text
infrastructure/ansible/
├── [`ansible.cfg`](infrastructure/ansible/ansible.cfg:1)
├── inventory/
│   ├── [`aws_ec2.yml`](infrastructure/ansible/inventory/aws_ec2.yml:1)
│   └── group_vars/
│       ├── [`all.yml`](infrastructure/ansible/inventory/group_vars/all.yml:1)
│       └── [`keycloak.yml`](infrastructure/ansible/inventory/group_vars/keycloak.yml:1)
├── playbooks/
│   ├── [`site.yml`](infrastructure/ansible/playbooks/site.yml:1)
│   ├── [`keycloak-install.yml`](infrastructure/ansible/playbooks/keycloak-install.yml:1)
│   └── [`keycloak-configure.yml`](infrastructure/ansible/playbooks/keycloak-configure.yml:1)
└── keycloak/
    ├── defaults/
    │   └── [`main.yml`](infrastructure/ansible/keycloak/defaults/main.yml:1)
    ├── vars/
    │   └── [`main.yml`](infrastructure/ansible/keycloak/vars/main.yml:1)
    ├── tasks/
    │   ├── [`main.yml`](infrastructure/ansible/keycloak/tasks/main.yml:1)
    │   ├── [`prerequisites.yml`](infrastructure/ansible/keycloak/tasks/prerequisites.yml:1)
    │   ├── [`install.yml`](infrastructure/ansible/keycloak/tasks/install.yml:1)
    │   ├── [`database.yml`](infrastructure/ansible/keycloak/tasks/database.yml:1)
    │   ├── [`configure.yml`](infrastructure/ansible/keycloak/tasks/configure.yml:1)
    │   └── [`ssl.yml`](infrastructure/ansible/keycloak/tasks/ssl.yml:1)
    ├── handlers/
    │   └── [`main.yml`](infrastructure/ansible/keycloak/handlers/main.yml:1)
    ├── templates/
    │   ├── [`keycloak.conf.j2`](infrastructure/ansible/keycloak/templates/keycloak.conf.j2:1)
    │   └── [`keycloak.service.j2`](infrastructure/ansible/keycloak/templates/keycloak.service.j2:1)
    └── meta/
        └── [`main.yml`](infrastructure/ansible/keycloak/meta/main.yml:1)
```

## Configuration Files

### ansible.cfg
Key settings:
```ini
[defaults]
inventory = ./inventory/aws_ec2.yml
host_key_checking = False
remote_user = ec2-user
private_key_file = ~/.ssh/id_rsa
...
```
Configuration located at [`ansible.cfg`](infrastructure/ansible/ansible.cfg:1).

### Inventory (`aws_ec2.yml`)
Dynamic AWS EC2 inventory plugin configured in [`aws_ec2.yml`](infrastructure/ansible/inventory/aws_ec2.yml:1):
- `regions`: list of AWS regions  
- `profile`: AWS CLI profile name  
- `filters`: tag and instance state filters  
- `keyed_groups`: group hosts by tag values  
- `groups`: static group definitions  
- `hostnames`: methods to determine host address  
- `compose`: maps EC2 attributes to Ansible variables  

## Group Variables

### all.yml
Global variables applied to all hosts (`group_vars/all.yml:1`):
- `aws_region`, `aws_profile`  
- `project_name`, `deployment_environment`  
- `ansible_ssh_common_args`, `ansible_python_interpreter`  
- `terraform_dir`, `resource_tags`  
- SSL toggles: `keycloak_https_required`, `keycloak_ssl_required`

### keycloak.yml
Keycloak host-specific variables (`group_vars/keycloak.yml:1`):
- Download & runtime:
  - `keycloak_version`, `keycloak_download_url`  
  - Installation: `keycloak_install_dir`, `keycloak_config_dir`, `keycloak_data_dir`, `keycloak_log_dir`  
- Service:
  - `keycloak_service_user`, `keycloak_service_group`  
  - Ports: `keycloak_http_port`, `keycloak_https_port`, `keycloak_management_port`  
- Database:
  - `keycloak_db_vendor`, `keycloak_db_host`, `keycloak_db_port`, `keycloak_db_name`, `keycloak_db_username`, `keycloak_db_password`  
- SSL:
  - `keycloak_enable_ssl`, `keycloak_keystore_password`  
- JVM options: `keycloak_java_opts`

## Playbooks

### site.yml
Deploys the Keycloak role to all hosts in group `keycloak`. Includes pre-tasks for debug information and waiting for connectivity.
```
ansible-playbook -i inventory/aws_ec2.yml playbooks/site.yml
```

### keycloak-install.yml
Runs only installation tasks of the Keycloak role (`install` tag).
```
ansible-playbook -i inventory/aws_ec2.yml playbooks/keycloak-install.yml -t install
```

### keycloak-configure.yml
Runs only configuration tasks of the Keycloak role (`configure` tag).
```
ansible-playbook -i inventory/aws_ec2.yml playbooks/keycloak-configure.yml -t configure
```

## Keycloak Role
The `keycloak` role installs and configures Keycloak:

- **defaults/main.yml**: default role variables  
- **vars/main.yml**: variables with no defaults  
- **tasks/**: task definitions split into:
  - `prerequisites.yml`  
  - `install.yml`  
  - `database.yml`  
  - `configure.yml`  
  - `ssl.yml`  
- **handlers/main.yml**: handlers for service restarts  
- **templates/**: Jinja2 templates for `keycloak.conf` and systemd service  
- **meta/main.yml**: role metadata  

## Example Usage
Run full deployment:
```bash
ansible-playbook -i infrastructure/ansible/inventory/aws_ec2.yml infrastructure/ansible/playbooks/site.yml