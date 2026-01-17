# Quick Reference

Quick lookup guide for common tasks and commands in RHIS deployments.

## Command Quick Reference

### Ansible

```bash
# Run playbook
ansible-playbook site.yml -i inventory/hosts

# Syntax check
ansible-playbook site.yml --syntax-check

# Dry run
ansible-playbook site.yml -i inventory/hosts --check

# Run with tags
ansible-playbook site.yml --tags deploy_aap

# Run specific host
ansible-playbook site.yml -i inventory/hosts -l satellite.prod.spg

# Vault operations
ansible-vault create vault.yml
ansible-vault edit vault.yml
ansible-vault view vault.yml

# Encrypt/decrypt files
ansible-vault encrypt file.yml
ansible-vault decrypt file.yml
```

### Satellite

```bash
# Register system
subscription-manager register
subscription-manager attach --pool=<pool-id>

# Check registration
subscription-manager status
subscription-manager list --available

# Sync repository
hammer repository synchronize --id <repo-id> --organization "Org"

# List hosts
hammer host list --organization "Org"

# Find package
hammer package list --search "<package-name>" --organization "Org"

# Execute remote command
hammer job-invocation create \
  --job-template "Run Command - Script Default" \
  --inputs command="<command>" \
  --search-query "hostgroup ~ Production"
```

### IdM

```bash
# User management
ipa user-add <username> --first "<first>" --last "<last>"
ipa user-find <username>
ipa user-mod <username> --email=<email>
ipa user-del <username>

# Group management
ipa group-add <groupname> --desc "<description>"
ipa group-add-member <groupname> --users <username>
ipa group-remove-member <groupname> --users <username>

# Keytab generation
ipa-getkeytab -s idm.example.com -p <principal> -k <keytab-file>

# Kerberos ticket
kinit <username>
klist

# LDAP search
ldapsearch -x -h idm.example.com -b "dc=example,dc=com" "cn=*"
```

### AAP

```bash
# Check services
systemctl status controller receiver dispatcher

# View logs
docker logs -f aap-controller-1
docker logs -f aap-postgres-1

# Run template from CLI
awx-cli job launch --template="<template-name>" --extra-vars="<vars>"

# Backup database
docker exec aap-postgres-1 pg_dump -U awx awx > backup.sql

# Reset admin password
docker exec aap-controller-1 awx-manage changepassword admin
```

### libvirt

```bash
# List VMs
virsh list --all

# Create VM
virt-install --name <vm-name> --memory 4096 --vcpus 2 \
  --disk size=50 --cdrom /path/to/iso.iso

# Connect to console
virsh console <vm-name>

# Clone VM
virt-clone -o <source-vm> -n <new-vm> -f /var/lib/libvirt/images/<new-vm>.qcow2

# Snapshot operations
virsh snapshot-create-as <vm-name> <snapshot-name>
virsh snapshot-revert <vm-name> <snapshot-name>
virsh snapshot-delete <vm-name> <snapshot-name>

# VM power operations
virsh start <vm-name>
virsh shutdown <vm-name>
virsh destroy <vm-name>  # Force power off
```

## File Locations

### Ansible

```
/home/sgallego/Downloads/RedHat_Management/
├── site.yml                    # Main playbook
├── playbooks/                  # Playbook directory
├── roles/                      # Ansible roles
├── inventory/                  # Inventory files
├── group_vars/                 # Group variables
├── host_vars/                  # Host variables
└── vault.yml                   # Encrypted secrets
```

### Satellite

```
/opt/
├── satellite-installer/        # Installer directory
├── foreman/                    # Foreman application
└── rh-postgresql-12/           # Database

Configuration:
/etc/foreman/                   # Foreman config
/etc/foreman-proxy/             # Proxy config
/var/lib/foreman/               # Foreman data
```

### IdM

```
/etc/ipa/                       # IdM configuration
/var/lib/dirsrv/                # Directory server data
/var/log/krb5kdc.log            # Kerberos logs
/var/log/kadmind.log            # Kadmin logs
/var/log/dirsrv/                # Directory server logs
```

### AAP

```
/opt/aap-setup/                 # Setup directory
/opt/aap-installer/             # Installer
/var/lib/docker/volumes/        # Container volumes
/var/lib/awx/                   # AWX data
/var/log/containers/            # Container logs
```

## Port Reference

| Service | Protocol | Port |
|---------|----------|------|
| HTTP | TCP | 80 |
| HTTPS | TCP | 443 |
| SSH | TCP | 22 |
| DNS | UDP/TCP | 53 |
| Kerberos | UDP/TCP | 88 |
| LDAP | TCP | 389 |
| LDAPS | TCP | 636 |
| PostgreSQL | TCP | 5432 |
| Tomcat | TCP | 8080 |
| Foreman | TCP | 3000 |
| Grafana | TCP | 3000 |
| Docker Registry | TCP | 5000 |
| Receptor | TCP | 27199 |
| libvirt QEMU | TCP | 16509 |

## URL Reference

| Component | URL |
|-----------|-----|
| AAP Controller | https://aap.example.com |
| Satellite | https://satellite.example.com |
| IdM | https://idm.example.com |
| Foreman API | https://satellite.example.com/api/v2 |
| AAP API | https://aap.example.com/api/v2 |
| IdM API | https://idm.example.com/ipa/json |
| Grafana | https://aap.example.com:3000 |

## Credential Variables

### Vault Example

```yaml
vault_satellite_user: admin
vault_satellite_password: SecurePassword123!
vault_idm_admin_password: AdminPassword123!
vault_aap_admin_password: AAP_Password123!
vault_db_admin_password: DBPassword123!
```

### Activation Keys

```
rhel8-key              # RHEL 8 systems
rhel9-key              # RHEL 9 systems
satellite-key          # Satellite systems
aap-key               # AAP systems
```

## Common Scenarios

### Register System to Satellite

```bash
# 1. Download CA certificate
wget https://satellite.example.com/pub/katello-ca-consumer-latest.noarch.rpm
sudo rpm -Uvh katello-ca-consumer-latest.noarch.rpm

# 2. Register with activation key
sudo subscription-manager register \
  --activationkey rhel8-key \
  --org "Default Organization"

# 3. Verify
sudo subscription-manager status
```

### Create User in IdM and Add to Group

```bash
# 1. Create user
ipa user-add john --first "John" --last "Doe" --email john@example.com

# 2. Set password
ipa user-mod john --password

# 3. Create or find group
ipa group-add sysadmins --desc "System Administrators"

# 4. Add user to group
ipa group-add-member sysadmins --users john
```

### Deploy AAP Template Targeting Satellite Inventory

```yaml
---
- name: Example deployment
  hosts: all
  gather_facts: yes
  tasks:
    - name: Update packages
      yum:
        name: "*"
        state: latest
      when: ansible_os_family == "RedHat"

    - name: Install services
      package:
        name:
          - httpd
          - mod_ssl
        state: present
```

### Clone and Snapshot VM in libvirt

```bash
# Clone VM
virt-clone -o original-vm -n cloned-vm \
  -f /var/lib/libvirt/images/cloned-vm.qcow2

# Start cloned VM
virsh start cloned-vm

# Create snapshot before deployment
virsh snapshot-create-as cloned-vm \
  --name pre-deployment \
  --description "Snapshot before deployment"

# Run deployment...

# Revert if needed
virsh snapshot-revert cloned-vm pre-deployment
```

## Troubleshooting Quick Commands

```bash
# System info
uname -a
hostnamectl status
timedatectl status
df -h

# Network
ip addr
ip route
netstat -tlnp
firewall-cmd --list-all

# Services
systemctl status
systemctl list-units --failed

# Logs
journalctl -xe
tail -100f /var/log/messages

# SELinux
getenforce
semanage fcontext -l

# Kerberos
kinit -R        # Renew ticket
kdestroy        # Destroy ticket
klist           # List tickets
```

---

See [Glossary](./GLOSSARY.md) for term definitions and [Troubleshooting](../troubleshooting/) for detailed guides.
