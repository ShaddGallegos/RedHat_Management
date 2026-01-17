# AAP 2.6 Deployment Guide

Complete guide for deploying Red Hat Ansible Automation Platform 2.6.

## Prerequisites

- RHEL 8.6+ or RHEL 9.0+
- 8 vCPU, 16 GB RAM minimum (32 GB recommended)
- 100 GB disk space
- Network connectivity to Red Hat repositories
- Red Hat subscription or trial access

## Pre-Deployment

### 1. System Preparation

```bash
# Update system
sudo yum update -y

# Install required packages
sudo yum install -y \
  gcc \
  libffi-devel \
  openssl-devel \
  python3-devel \
  git \
  docker

# Enable services
sudo systemctl enable docker
sudo systemctl start docker
```

### 2. Container Setup

AAP 2.6 uses containerized deployment:

```bash
# Extract setup bundle
cd /opt
tar xzf ansible-automation-platform-2.6-bundle.tar.gz
cd aap-setup

# Create inventory
cp inventory.example inventory
```

### 3. Configure Inventory

Edit `inventory` for your environment:

```ini
[all:vars]
ansible_user=root
ansible_become=False
admin_user=admin
admin_password=SecurePassword123!

[controller]
hostname.example.com ansible_host=192.168.1.10

[database]
hostname.example.com ansible_host=192.168.1.10

[automationhub]
hostname.example.com ansible_host=192.168.1.10

[receptor_execution_nodes]
# execution_node.example.com ansible_host=192.168.1.20
```

## Deployment

### Standard Installation

```bash
# Run installer
./setup.sh -e @extra_vars.yml

# Monitor installation
sudo docker ps -a
sudo docker logs -f aap-controller-1
```

### High-Availability Setup

For HA deployment, configure multiple nodes:

```ini
[all:vars]
cluster_name=aap-cluster

[controller]
control-1.example.com
control-2.example.com  
control-3.example.com

[database]
db-1.example.com
db-2.example.com
db-3.example.com
```

## Post-Deployment

### 1. Access Controller

- URL: `https://hostname.example.com`
- Default username: `admin`
- Default password: Set in inventory

### 2. Initial Configuration

1. Change admin password
2. Configure organizations
3. Set up credentials
4. Create projects
5. Configure inventory sources

### 3. License

```bash
# Upload license via UI
Settings → License

# Or via API
curl -X POST https://hostname/api/v2/config/ \
  -H "Content-Type: application/json" \
  -d @license.json
```

## Integration with Satellite

### 1. Configure Satellite Inventory Plugin

In AAP Controller, create inventory using Satellite plugin:

- **Name**: Satellite Inventory
- **Plugin**: Red Hat Satellite 6
- **Server**: satellite.example.com
- **Organization**: Default
- **Verify SSL**: false (for self-signed certs)

### 2. Create Job Template

```yaml
- name: Satellite Sync
  hosts: localhost
  tasks:
    - name: Sync Satellite inventory
      community.general.redfish_info:
        baseuri: "{{ satellite_url }}"
        username: "{{ satellite_user }}"
        password: "{{ satellite_pass }}"
        category: Systems
```

## Integration with IdM

### 1. Configure LDAP Authentication

In AAP Controller settings:

```
Settings → Authentication → LDAP

AUTH_LDAP_SERVER_URI = ldap://idm.example.com
AUTH_LDAP_BIND_DN = cn=admin,cn=accounts,dc=example,dc=com
AUTH_LDAP_BIND_PASSWORD = <password>
AUTH_LDAP_USER_SEARCH_BASE = cn=users,cn=accounts,dc=example,dc=com
```

### 2. Map LDAP Groups to Teams

```bash
# Via AAP UI
Settings → Authentication → LDAP Team Maps

[
  {
    "ldapgrouptype": "cn",
    "remove": true,
    "remove_organization": true
  }
]
```

## Clustering

### Scale Controller Nodes

Add execution nodes to distribute job load:

```bash
# On execution node
sudo ./setup.sh -e @extra_vars.yml -k

# Configure in controller
Settings → Controller Settings → Instances
```

### Add Receptor Nodes

For hop nodes and isolated execution:

```ini
[receptor_execution_nodes]
receptor-1.example.com receptor_control_plane_port=27199
receptor-2.example.com receptor_control_plane_port=27199
```

## Maintenance

### Backup

```bash
# Database backup
sudo docker exec -it aap-postgres-1 pg_dump -U awx awx > backup.sql

# Full backup (include credentials)
sudo tar czf aap-backup-$(date +%Y%m%d).tar.gz \
  /opt/aap-setup \
  /var/lib/docker/volumes
```

### Upgrades

```bash
# Download new version
wget https://releases.ansible.com/aap/2.6/latest/setup-bundle.tar.gz

# Run upgrade
cd /opt/aap-setup
./setup.sh -e upgrade=true
```

### Monitoring

- URL: `https://hostname:3000` (Grafana)
- Database: PostgreSQL on port 5432
- Container health: `docker ps`

## Troubleshooting

### Check Service Status

```bash
# All containers running?
sudo docker ps -a

# Check logs
sudo docker logs aap-controller-1

# Database connectivity
sudo docker exec aap-postgres-1 pg_isready
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Admin password reset | `docker exec aap-controller-1 awx-manage changepassword admin` |
| License expired | Upload valid license in UI |
| High memory usage | Increase JVM memory: `-e CONTROLLER_SETTINGS_EXTRA="{...}"` |
| Inventory sync fails | Check Satellite plugin credentials |

## References

- [AAP Administration](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/administration/)
- [AAP Installation](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/containerized_setup/)
- [Automation Hub](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/html/automation_hub_user_guide/)
