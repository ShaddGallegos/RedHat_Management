# Satellite 6.18 Deployment Guide

Complete guide for deploying Red Hat Satellite 6.18.

## Prerequisites

- RHEL 8.6+ or RHEL 9.0+
- 12 vCPU, 32 GB RAM minimum (64 GB recommended for large deployments)
- 500 GB+ disk space (1+ TB recommended with synced repositories)
- Network connectivity to CDN for repository sync
- Red Hat subscription with Satellite entitlement

## Pre-Deployment

### 1. System Preparation

```bash
# Update system
sudo yum update -y

# Register with Red Hat
sudo subscription-manager register
sudo subscription-manager attach --pool=<pool-id>

# Enable Satellite repositories
sudo subscription-manager repos --enable=rhel-*-scenario_satellite-6.18-*-rpms

# Install Satellite packages
sudo yum install -y scenario_satellite scenario_satellite-cli
```

### 2. Firewall Configuration

```bash
# Open required ports
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --add-port=443/tcp --permanent
sudo firewall-cmd --add-port=5000/tcp --permanent
sudo firewall-cmd --add-port=8000/tcp --permanent
sudo firewall-cmd --add-port=9090/tcp --permanent
sudo firewall-cmd --reload
```

### 3. Database Preparation

Satellite uses PostgreSQL:

```bash
# Install PostgreSQL
sudo yum install -y postgresql-server postgresql-contrib

# Initialize database
sudo postgresql-setup initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

## Installation

### 1. Run Satellite Installer

```bash
# Start installer
sudo scenario_satellite-installer

# Or with options
sudo scenario_satellite-installer \
  --scenario scenario_satellite \
  --foreman-initial-admin-username admin \
  --foreman-initial-admin-password SecurePassword123! \
  --foreman-admin-email admin@example.com \
  --foreman-server-ssl-cert /path/to/cert.pem \
  --foreman-server-ssl-key /path/to/key.pem \
  --foreman-server-ssl-ca-cert /path/to/ca.pem
```

### 2. Monitor Installation

Installation takes 30-60 minutes:

```bash
# Watch installer progress
sudo tail -f /var/log/foreman-installer/scenario_satellite.log

# Check services
sudo systemctl status tomcat foreman postgresql foreman-proxy
```

## Post-Installation

### 1. Access Satellite

- URL: `https://scenario_satellite.example.com`
- Username: `admin`
- Password: Set during installation

### 2. Initial Configuration

#### Configure Organizations & Locations

```bash
scenario_satellite-cli \
  --username admin \
  --password <password> \
  organization create \
  --name "Default Organization" \
  --url https://scenario_satellite.example.com
```

#### Create Activation Keys

```bash
scenario_satellite-cli \
  --username admin \
  activation-key create \
  --name "rhel8-key" \
  --organization "Default Organization" \
  --release-version "8"
```

### 3. Repository Synchronization

#### Enable Repositories

In Satellite UI:

1. **Content** → **Red Hat Repositories**
2. Search for repositories (e.g., RHEL 8, Satellite)
3. Enable desired repositories

#### Sync Repositories

```bash
# Via UI
Content → Sync Status → Select repos → Sync Selected

# Via CLI
hammer repository synchronize \
  --id <repo-id> \
  --organization "Default Organization"
```

#### Sync Policies

- **On-demand**: Packages synced when systems request them
- **Immediate**: Sync all packages now (uses large disk space)
- **Scheduled**: Sync on schedule (recommended)

## Content Management

### 1. Content Views

Create content views to manage package versions:

```bash
hammer content-view create \
  --name "rhel8-cv" \
  --description "RHEL 8 Content View" \
  --organization "Default Organization"
```

### 2. Publish Content Views

```bash
hammer content-view publish \
  --name "rhel8-cv" \
  --organization "Default Organization"
```

### 3. Promote Content

Promote through lifecycle environments:

```
Development → Staging → Production
```

```bash
hammer content-view version promote \
  --content-view "rhel8-cv" \
  --version 1 \
  --to-lifecycle-environment "Production"
```

## System Management

### 1. Register Systems

On managed systems:

```bash
# Download activation key
wget https://scenario_satellite.example.com/pub/katello-ca-consumer-latest.noarch.rpm
sudo rpm -Uvh katello-ca-consumer-latest.noarch.rpm

# Register
sudo yum -y install katello-agent
sudo subscription-manager register \
  --activationkey rhel8-key \
  --org "Default Organization"
```

### 2. Remote Execution

Run commands on systems:

```bash
# Via UI
Infrastructure → Hosts → Select host → Run Command

# Via CLI
hammer job-invocation create \
  --job-template "Run Command - Script Default" \
  --inputs command="yum update -y" \
  --search-query "hostgroup ~ Production"
```

### 3. Configuration Management (Puppet)

Deploy configurations:

```bash
# Upload Puppet modules
hammer puppet-module upload \
  --file /path/to/module.tar.gz

# Apply classes to hosts
hammer hostgroup set-parameters \
  --name "production" \
  --parameters classes=base,ssh
```

## Satellite Integration with AAP

### 1. Configure AAP Inventory Plugin

In AAP Controller:

1. **Inventories** → **Create Inventory**
2. **Source**: Red Hat Satellite 6
3. **Host**: scenario_satellite.example.com
4. **Organization**: Default
5. **Update on Launch**: Yes

### 2. Create Remediation Playbooks

Use Satellite facts for targeting:

```yaml
---
- name: Patch Systems from Satellite Inventory
  hosts: all
  tasks:
    - name: Update packages
      yum:
        name: "*"
        state: latest
      when: ansible_distribution_major_version == "8"
```

## Performance Tuning

### Database Optimization

```bash
# Increase PostgreSQL cache
sudo -u postgres psql -c "ALTER SYSTEM SET shared_buffers='16GB';"
sudo -u postgres psql -c "ALTER SYSTEM SET effective_cache_size='32GB';"
sudo systemctl restart postgresql
```

### Foreman Tuning

Edit `/etc/foreman/settings.yaml`:

```yaml
# Increase RAM for Java
:foreman_url: https://scenario_satellite.example.com
:facts_cache_enabled: true
:search_duration: 3600
```

### Repository Sync Optimization

- Schedule syncs during off-peak hours
- Use incremental sync when possible
- Run sync jobs in parallel on multiple Satellite instances

## Backup and Recovery

### Backup

```bash
# Full backup
sudo scenario_satellite-backup --verbose /mnt/backup/

# Incremental backup
sudo scenario_satellite-backup --incremental /mnt/backup/
```

### Restore

```bash
# Restore from backup
sudo scenario_satellite-restore --verbose /mnt/backup/scenario_satellite-backup-*.tar.gz
```

## Satellite Integration with IdM

### Configure LDAP Authentication

**Settings** → **Authentication** → **LDAP**

```yaml
ldap_url: ldap://idm.example.com
ldap_base: cn=users,cn=accounts,dc=example,dc=com
ldap_user_attr: uid
ldap_group_attr: cn
ldap_group_base: cn=groups,cn=accounts,dc=example,dc=com
```

## Maintenance

### Update Satellite

```bash
# Check for updates
sudo yum check-update scenario_satellite

# Apply updates
sudo yum update -y scenario_satellite

# Run installer again
sudo scenario_satellite-installer
```

### Clean Up Old Packages

```bash
# Remove package duplicates
hammer repository sync \
  --repository "repo-name" \
  --mirror-on-sync true
```

## Troubleshooting

### Check Service Status

```bash
# All services running?
sudo systemctl status foreman foreman-proxy tomcat postgresql

# Check logs
sudo tail -100f /var/log/foreman/production.log
sudo tail -100f /var/log/tomcat/catalina.out
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Slow repository sync | Increase worker threads, schedule off-peak |
| Database connection errors | Check PostgreSQL: `sudo systemctl restart postgresql` |
| SSL certificate issues | Regenerate cert: `foreman-installer --reset-foreman-server-ssl-cert` |
| Systems not checking in | Verify Katello agent: `sudo yum reinstall katello-agent` |

## References

- [Satellite 6.18 Documentation](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.18/)
- [Satellite Installation](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.18/html/installing_satellite_server/)
- [Content Management Guide](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.18/html/content_management_guide/)
