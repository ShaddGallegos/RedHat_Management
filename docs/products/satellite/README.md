# Red Hat Satellite 6.18

## Synopsis

Red Hat Satellite is a systems management platform that provides visibility and control over your Red Hat infrastructure. Satellite 6.18 enables:

- **Patch Management** - Automated updates and patch deployment
- **Content Management** - Synchronized content repositories
- **Provisioning** - Automated system provisioning (PXE, image-based)
- **Compliance** - Configuration and security compliance monitoring
- **Remote Execution** - Job execution across managed systems
- **Subscription Management** - License and subscription tracking

Deployed via RHIS, Satellite acts as the content and lifecycle management hub for all Red Hat products in your infrastructure.

---

## Quick Start

### Prerequisites
- Red Hat Enterprise Linux 9.x
- Minimum 16GB RAM, 4 vCPU, 500GB storage
- Network connectivity to RHN or Satellite server
- DNS properly configured (FQDN required)

### 1. Configure Inventory
Update `inventory/hosts`:
```ini
[satellite]
satellite.example.com

[satellite:vars]
satellite_admin_user=admin
satellite_admin_password=SecurePass123
satellite_hostname=satellite.example.com
satellite_domain=example.com
```

### 2. Configure Settings
Edit `group_vars/satellite.yml`:
```yaml
satellite_version: "6.18"
satellite_org: "Default Organization"
satellite_location: "Default Location"
satellite_admin_email: "admin@example.com"
```

### 3. Deploy Satellite
```bash
ansible-playbook site.yml -t satellite
```

### 4. Access Satellite
- **URL**: https://satellite.example.com
- **Username**: admin
- **Password**: (from group_vars)

---

## Installation

### Detailed Installation Steps

#### Step 1: System Preparation
```bash
# Update system
yum update -y

# Install required packages
yum install -y satellite-server satellite-cli

# Configure firewall
firewall-cmd --permanent --add-service=satellite-server
firewall-cmd --permanent --add-port=5646/tcp
firewall-cmd --permanent --add-port=5647/tcp
firewall-cmd --reload

# Prepare storage
lvcreate -L 500G -n satellite /dev/vg_name
mkfs.xfs /dev/vg_name/satellite
mkdir -p /var/lib/satellite
mount /dev/vg_name/satellite /var/lib/satellite
```

#### Step 2: Pre-Installation Configuration
Create `/usr/lib/python3/site-packages/satellite/settings.yaml`:
```yaml
---
satellite:
  server:
    hostname: satellite.example.com
    domain: example.com
    
  database:
    adapter: postgresql
    host: localhost
    port: 5432
    database: foreman
    username: foreman
    
  storage:
    path: /var/lib/satellite
    size_gb: 500
    
  admin:
    user: admin
    password_hash: "{{ vault_satellite_admin_password }}"
    email: admin@example.com
```

#### Step 3: Run Installation Role
```bash
# Deploy Satellite via role
ansible-playbook -i inventory/hosts \
  roles/satellite_6_18_deployment/tasks/main.yml \
  --vault-password-file ~/.ansible/conf/vault.txt

# Or full playbook
ansible-playbook site.yml \
  -e "deployment_scenario=satellite" \
  --tags satellite
```

#### Step 4: Post-Installation Configuration
```bash
# Initialize Satellite
satellite-installer --scenario satellite \
  --foreman-initial-admin-username admin \
  --foreman-initial-admin-password "SecurePass123" \
  --foreman-initial-organization "Default Organization" \
  --foreman-initial-location "Default Location"

# Configure subscriptions
satellite-manage-repos --enable rhel-*-satellite-6.18-*
yum update -y

# Sync content
satellite-sync --all
```

#### Step 5: Verification
```bash
# Check services
systemctl status foreman
systemctl status httpd
systemctl status postgresql

# Verify database
sudo -u postgres psql -l | grep foreman

# Test API
curl -k https://satellite.example.com/api/v2/status \
  -u admin:password
```

---

## Integration with RHIS Project

### 1. Credential Storage
Store Satellite credentials securely:
```bash
# Add to group_vars/vault.yml
vault_satellite_admin_password: "SecurePass123"
vault_satellite_api_token: "TOKEN..."
vault_satellite_ssh_user: "root"
vault_satellite_ssh_key: |
  -----BEGIN RSA PRIVATE KEY-----
  ...
  -----END RSA PRIVATE KEY-----
```

### 2. Inventory Synchronization
```yaml
# playbooks/sync_satellite_inventory.yml
---
- name: Sync Satellite Inventory to Ansible
  hosts: localhost
  vars:
    satellite_url: "https://satellite.example.com"
    satellite_user: "admin"
    satellite_password: "{{ vault_satellite_admin_password }}"
  
  tasks:
    - name: Get hosts from Satellite
      community.general.foreman_host:
        username: "{{ satellite_user }}"
        password: "{{ satellite_password }}"
        server_url: "{{ satellite_url }}"
        validate_certs: false
        state: present
      register: satellite_hosts
    
    - name: Generate inventory
      template:
        src: satellite_inventory.j2
        dest: inventory/satellite_hosts.yml
```

### 3. Content Management
```yaml
# group_vars/satellite.yml
satellite_repositories:
  - name: "rhel-9-for-x86_64-baseos-rpms"
    organization: "Default Organization"
    enabled: true
  
  - name: "rhel-9-for-x86_64-appstream-rpms"
    organization: "Default Organization"
    enabled: true
  
  - name: "satellite-tools-6.18-for-rhel-9-x86_64-rpms"
    organization: "Default Organization"
    enabled: true

satellite_sync_schedule: "0 2 * * *"  # 2 AM daily
```

### 4. Provisioning Integration
```yaml
# playbooks/provision_with_satellite.yml
---
- name: Provision Host via Satellite
  hosts: localhost
  vars:
    satellite_url: "https://satellite.example.com"
    host_group: "Production/Linux"
    compute_resource: "libvirt"
  
  tasks:
    - name: Create host in Satellite
      community.general.foreman_host:
        hostname: "{{ new_hostname }}"
        organization: "Default Organization"
        location: "Default Location"
        hostgroup: "{{ host_group }}"
        build: true
        server_url: "{{ satellite_url }}"
        username: admin
        password: "{{ vault_satellite_admin_password }}"
        state: present
        compute_resource: "{{ compute_resource }}"
        compute_profile: "2-CPUs, 4GB RAM"
```

---

## Update & Upgrade

### Prepare for Upgrade
```bash
# 1. Backup Satellite database
pg_dump foreman | gzip > /backup/satellite_db_$(date +%Y%m%d).sql.gz

# 2. Backup configuration
tar -czf /backup/satellite_config_$(date +%Y%m%d).tar.gz \
  /etc/foreman/ /var/lib/pulp/

# 3. Check upgrade path
satellite-installer --version
```

### Upgrade Process
```bash
# Update packages
yum update -y satellite-*

# Run installer to apply changes
satellite-installer --scenario satellite

# Verify upgrade
satellite-installer --list-tuning

# Check status
satellite-admin status
```

### Verify After Upgrade
```bash
# Test API
curl -k https://satellite.example.com/api/v2/status

# Check database integrity
psql foreman -c "SELECT * FROM users LIMIT 1;"

# Verify services
systemctl status foreman
systemctl status httpd
```

---

## Examples

### Example 1: Add Repository
```yaml
---
- name: Add RHEL 9 AppStream Repository
  hosts: satellite
  
  tasks:
    - name: Create Product
      community.general.foreman_product:
        name: "RHEL 9"
        organization: "Default Organization"
        server_url: "https://{{ inventory_hostname }}"
        username: admin
        password: "{{ vault_satellite_admin_password }}"
    
    - name: Add Repository
      community.general.foreman_repository:
        name: "rhel-9-appstream"
        product: "RHEL 9"
        content_type: "yum"
        url: "https://cdn.redhat.com/content/..."
        organization: "Default Organization"
        server_url: "https://{{ inventory_hostname }}"
        username: admin
        password: "{{ vault_satellite_admin_password }}"
```

### Example 2: Create Activation Key
```bash
#!/bin/bash
# scripts/bash/create_satellite_activation_key.sh

SATELLITE_URL="https://satellite.example.com"
ORG="Default Organization"
LIFETIME_DAYS=365

hammer activation-key create \
  --name "Production Servers" \
  --organization "$ORG" \
  --unlimited-hosts \
  --content-overrides-enabled true

hammer activation-key add-subscription \
  --name "Production Servers" \
  --organization "$ORG" \
  --subscription-id 1
```

### Example 3: Provision Host via PXE
```yaml
---
- name: Provision Host via Satellite PXE
  hosts: satellite
  
  vars:
    new_hostname: "webserver-prod-01"
    host_group: "Production/Web Servers"
    compute_resource: "libvirt"
    mac_address: "52:54:00:12:34:56"
  
  tasks:
    - name: Create host record
      community.general.foreman_host:
        hostname: "{{ new_hostname }}"
        organization: "Default Organization"
        location: "Default Location"
        hostgroup: "{{ host_group }}"
        mac: "{{ mac_address }}"
        compute_resource: "{{ compute_resource }}"
        build: true
        server_url: "{{ inventory_hostname }}"
        username: admin
        password: "{{ vault_satellite_admin_password }}"
        state: present
    
    - name: Wait for PXE boot
      pause:
        minutes: 5
      
    - name: Verify host provisioning
      shell: >
        hammer host info --name {{ new_hostname }}
        --organization "Default Organization"
```

### Example 4: Content Sync Script
```python
#!/usr/bin/env python3
# scripts/python/satellite_content_sync.py

import requests
import json
import time

class SatelliteSync:
    def __init__(self, url, username, password):
        self.url = url
        self.session = requests.Session()
        self.session.auth = (username, password)
        self.session.verify = False
    
    def get_repositories(self):
        """Get all repositories"""
        response = self.session.get(
            f"{self.url}/api/v2/repositories/"
        )
        return response.json()['results']
    
    def sync_repository(self, repo_id):
        """Sync a repository"""
        payload = {}
        response = self.session.post(
            f"{self.url}/api/v2/repositories/{repo_id}/sync/",
            json=payload
        )
        return response.json()
    
    def sync_all(self):
        """Sync all repositories"""
        repos = self.get_repositories()
        for repo in repos:
            print(f"Syncing {repo['name']}...")
            task = self.sync_repository(repo['id'])
            print(f"  Task ID: {task['task']['id']}")
            time.sleep(5)

# Usage
sync = SatelliteSync(
    "https://satellite.example.com",
    "admin",
    "password"
)
sync.sync_all()
```

### Example 5: Remote Job Execution
```yaml
---
- name: Execute Remote Command via Satellite
  hosts: localhost
  
  tasks:
    - name: Create job template
      community.general.foreman_job_template:
        name: "Update System"
        job_category: "Commands"
        description: "Run system update"
        provider_type: "SSH"
        template: |
          #!/bin/bash
          yum update -y
        inputs:
          - name: command
            input_type: String
        server_url: "https://satellite.example.com"
        username: admin
        password: "{{ vault_satellite_admin_password }}"
    
    - name: Execute job on hosts
      shell: |
        hammer job-invocation create \
          --job-template "Update System" \
          --search-query "name ~ prod" \
          --input-values "command=yum update -y"
```

---

## Troubleshooting

### Issue: Satellite Service Won't Start
```bash
# Check logs
tail -f /var/log/foreman/production.log
journalctl -u foreman

# Verify database connection
psql -U foreman foreman -c "SELECT 1"

# Check disk space
df -h /var/lib/satellite
```

### Issue: Content Sync Fails
```bash
# Check repository connectivity
curl -v https://cdn.redhat.com/content/...

# View sync logs
tail -f /var/log/foreman/production.log | grep sync

# Reset sync
hammer repository update --id 1 --organization "Default Organization"
```

### Issue: Host Not Appearing in Satellite
```bash
# Check registration
subscription-manager status

# View registration logs
tail -f /var/log/rhsm/*

# Re-register if needed
subscription-manager unregister
subscription-manager register --org "Default Organization" \
  --activationkey "Production Servers"
```

---

## Additional Resources

- [Satellite 6.18 Documentation](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.18/)
- [Satellite API Guide](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.18/html-single/api/index)
- [Foreman Community](https://theforeman.org/)
- [RHIS Project Guide](../README.md)
- [Related: IdM Integration](../idm/README.md)

---

**Last Updated:** January 2026
**Supported Versions:** Satellite 6.18.x
**RHIS Compatibility:** All platforms (Libvirt, AWS, Azure, VMware, Nutanix)
