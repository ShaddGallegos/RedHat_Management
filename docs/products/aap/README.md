# Red Hat Ansible Automation Platform (AAP) 2.6

## Synopsis

Red Hat Ansible Automation Platform (AAP) is an enterprise automation solution that enables IT organizations to automate infrastructure provisioning, application deployment, and operational tasks at scale. AAP 2.6 is deployed through this RHIS project with containerized components including:

- **Automation Controller** - Job orchestration and execution engine
- **Automation Hub** - Private Ansible collection repository
- **Event-Driven Ansible (EDA)** - Event-driven automation capabilities
- **Receptor** - Network plugin for hybrid connectivity

**Key Features:**
- Multi-tenancy with RBAC (Role-Based Access Control)
- Credential management and secret handling
- Job templates and workflows
- Inventory management across multiple platforms
- Enterprise support and compliance

---

## Quick Start

### Prerequisites
- Red Hat Enterprise Linux 8.x or 9.x
- Minimum 16GB RAM, 4 vCPU
- Container runtime (Podman or Docker)
- Network access to Red Hat Automation Hub

### 1. Initial Setup
```bash
# Source credentials
source scripts/bash/run_setup.sh

# Initialize RHIS menu
./scripts/bash/run_setup.sh

# Configure AAP deployment
./scripts/RHIS-Menu.sh
```

### 2. Configure Inventory
Update `inventory/hosts` or `inventory/deployment.yml`:
```yaml
[aap]
aap-controller.example.com
aap-hub.example.com

[aap:vars]
aap_admin_user=admin
aap_admin_password=SecurePassword123
```

### 3. Deploy AAP
```bash
# Run the AAP setup role
ansible-playbook -i inventory/hosts site.yml -t aap

# Or use Makefile
make site
```

### 4. Access AAP
- **Controller URL**: https://aap-controller.example.com
- **Default Admin User**: admin
- **Initial Password**: (set in group_vars/aap.yml)

---

## Installation

### Full Installation Process

#### Step 1: Prepare Environment
```bash
cd /run/media/sgallego/SD_Card/GIT/RedHat_Management

# Install dependencies
python3 scripts/python/generate_ansible_cfg.py

# Set up Ansible configuration
source ~/.ansible/conf/env.yml
```

#### Step 2: Configure Group Variables
Edit `group_vars/aap.yml`:
```yaml
---
# AAP Configuration
aap_version: "2.6"
aap_admin_user: "admin"
aap_admin_password: "{{ vault_aap_admin_password }}"
aap_db_password: "{{ vault_aap_db_password }}"

# Container Settings
aap_container_registry: "quay.io/ansible"
aap_image_tag: "latest"

# Networking
aap_controller_host: "aap-controller.example.com"
aap_hub_host: "aap-hub.example.com"
aap_controller_port: 443
aap_hub_port: 443

# Database
aap_postgresql_host: "postgres.example.com"
aap_postgresql_port: 5432
aap_postgresql_database: "awx"
aap_postgresql_user: "awx"
```

#### Step 3: Run Installation Role
```bash
# Deploy with specific role
ansible-playbook -i inventory/hosts \
  -e "deployment_scenario=aap" \
  roles/aap_2_6_setup/tasks/main.yml

# Or via main playbook
ansible-playbook redhat_management-site.yml \
  --tags aap \
  --vault-password-file ~/.ansible/conf/vault.txt
```

#### Step 4: Verify Installation
```bash
# Check container status
podman ps | grep -E "controller|hub|eda"

# Test API connectivity
curl -k https://aap-controller.example.com/api/v2/me/ \
  -H "Authorization: Bearer YOUR_TOKEN"

# Verify database connection
psql -h postgres.example.com -U awx -d awx -c "SELECT version();"
```

---

## Integration with RHIS Project

### 1. Credential Integration
Store AAP credentials securely:
```bash
# Initialize vault
ansible-vault create group_vars/vault.yml

# Add AAP credentials
vault_aap_admin_password: "SecurePassword123"
vault_aap_db_password: "DBPassword456"
vault_aap_api_token: "TOKEN..."
```

### 2. Inventory Management
Use the inventory generator role:
```bash
# Generate dynamic inventory
ansible-playbook -i inventory/hosts playbooks/generate_inventory.yml

# Validate inventory
ansible-inventory -i inventory/hosts --list
```

### 3. Job Template Integration
Create job templates that reference other RHIS roles:
```yaml
- name: Deploy via RHIS
  hosts: all
  roles:
    - aap_2_6_setup
    - satellite_6_18_deployment
    - idm_integration
```

### 4. Multi-Platform Deployment
Define in `group_vars/aap.yml`:
```yaml
aap_deployment_platforms:
  - libvirt
  - aws
  - azure
  - vmware
```

---

## Update & Upgrade

### Upgrade to Latest AAP 2.6.x
```bash
# 1. Backup current configuration
ansible-playbook playbooks/backup_aap.yml

# 2. Update role
git pull origin main
pip install -r requirements.txt

# 3. Run upgrade playbook
ansible-playbook -i inventory/hosts \
  -e "aap_upgrade=true" \
  roles/aap_2_6_setup/tasks/upgrade.yml

# 4. Verify upgrade
./scripts/python/verify_aap_version.py
```

### Backup Before Upgrade
```bash
# Create full backup
podman exec awx-postgres-1 pg_dump -U awx awx | \
  gzip > /backup/aap_$(date +%Y%m%d).sql.gz

# Backup configurations
tar -czf /backup/aap_config_$(date +%Y%m%d).tar.gz \
  /etc/aap/ /var/lib/awx/
```

### Rollback Procedure
```bash
# If upgrade fails, rollback
ansible-playbook playbooks/restore_aap.yml \
  -e "restore_date=20260115"
```

---

## Examples

### Example 1: Basic Job Template
Create a playbook for deployment:
```yaml
---
- name: Deploy Infrastructure
  hosts: localhost
  gather_facts: yes
  
  vars:
    deployment_type: "production"
    environment: "prod"
  
  tasks:
    - name: Include infrastructure role
      include_role:
        name: infrastructure_prep
      
    - name: Include AAP setup
      include_role:
        name: aap_2_6_setup
```

### Example 2: Credential Management
```python
#!/usr/bin/env python3
# scripts/python/manage_aap_credentials.py

import requests
import json
from pathlib import Path

class AAPCredentialManager:
    def __init__(self, controller_url, username, password):
        self.url = controller_url
        self.session = requests.Session()
        self.session.auth = (username, password)
    
    def create_credential(self, name, credential_type, inputs):
        """Create new credential in AAP"""
        payload = {
            "name": name,
            "credential_type": credential_type,
            "inputs": inputs
        }
        response = self.session.post(
            f"{self.url}/api/v2/credentials/",
            json=payload
        )
        return response.json()
    
    def list_credentials(self):
        """List all credentials"""
        response = self.session.get(f"{self.url}/api/v2/credentials/")
        return response.json()

# Usage
manager = AAPCredentialManager(
    "https://aap-controller.example.com",
    "admin",
    "password"
)

# Create machine credential
cred = manager.create_credential(
    name="Production Servers",
    credential_type="machine",
    inputs={
        "username": "ansible",
        "ssh_key_data": open("/home/ansible/.ssh/id_rsa").read()
    }
)
print(json.dumps(cred, indent=2))
```

### Example 3: Workflow Integration
```yaml
---
- name: Complete Infrastructure Deployment
  hosts: localhost
  gather_facts: no
  
  tasks:
    - name: Deploy Infrastructure
      include_role:
        name: infrastructure_prep
      vars:
        target_platform: "libvirt"
    
    - name: Deploy Satellite
      include_role:
        name: satellite_6_18_deployment
      when: deploy_satellite | bool
    
    - name: Deploy AAP
      include_role:
        name: aap_2_6_setup
      vars:
        aap_version: "2.6"
    
    - name: Configure IdM Integration
      include_role:
        name: idm_integration
      when: idm_enabled | bool
    
    - name: Generate Reports
      include_role:
        name: ansible_cmdb_setup
```

### Example 4: Dynamic Inventory
```yaml
# inventory/aap_dynamic.yml
---
plugin: controllers
host: https://aap-controller.example.com
username: admin
password: "{{ aap_admin_password }}"
verify_ssl: false

keyed_groups:
  - key: execution_environment | default('default')
    parent_group: ee
  - key: organization_name | default('default')
    parent_group: organization
```

### Example 5: AAP Menu Integration
```bash
# scripts/bash/aap_menu.sh
#!/bin/bash

echo "=== AAP Management Menu ==="
echo "1. Deploy AAP 2.6"
echo "2. Create Job Template"
echo "3. Run Job"
echo "4. View Logs"
echo "5. Backup Configuration"
echo "6. Upgrade AAP"

read -p "Select option: " choice

case $choice in
    1) ansible-playbook -i inventory/hosts site.yml -t aap ;;
    2) ansible-playbook playbooks/create_job_template.yml ;;
    3) ansible-playbook playbooks/run_job.yml ;;
    4) podman logs -f awx-web-1 ;;
    5) ansible-playbook playbooks/backup_aap.yml ;;
    6) ansible-playbook roles/aap_2_6_setup/tasks/upgrade.yml ;;
esac
```

---

## Troubleshooting

### Issue: Controller Not Starting
```bash
# Check pod status
podman ps -a | grep awx

# View logs
podman logs awx-web-1

# Restart services
podman-compose -f /etc/aap/docker-compose.yml restart
```

### Issue: Database Connection Failed
```bash
# Verify PostgreSQL connection
psql -h postgres.example.com -U awx -d awx -c "SELECT 1"

# Check database configuration
grep -r "DATABASE_URL" /etc/aap/
```

### Issue: Credential Decryption Failure
```bash
# Verify encryption key
cat /etc/aap/awx/SECRET_KEY

# Reset credentials
ansible-playbook playbooks/reset_credentials.yml
```

---

## Additional Resources

- [AAP Official Documentation](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/)
- [AAP REST API Reference](https://docs.ansible.com/automation-controller/latest/html/userguide/api.html)
- [RHIS Project Guide](../README.md)
- [Related: Automation Hub](../automation-hub/README.md)
- [Related: Event-Driven Ansible](../eda/README.md)

---

**Last Updated:** January 2026
**Supported Versions:** AAP 2.6.x
**RHIS Compatibility:** All platforms (Libvirt, AWS, Azure, VMware, Nutanix)
