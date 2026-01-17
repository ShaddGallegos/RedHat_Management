# Red Hat Identity Management (IdM)

## Synopsis

Red Hat Identity Management (IdM) is an integrated solution for managing users, groups, services, and authentication across your infrastructure. Built on FreeIPA, IdM provides:

- **User & Group Management** - Centralized user and group directory
- **Authentication** - LDAP, Kerberos, and certificate-based auth
- **Authorization** - RBAC for infrastructure and applications
- **Single Sign-On (SSO)** - Integrated Kerberos realm
- **Certificate Management** - CA services for infrastructure
- **DNS Management** - Integrated DNS for infrastructure naming

When deployed via RHIS, IdM serves as the identity backbone for all infrastructure management.

---

## Quick Start

### Prerequisites
- Red Hat Enterprise Linux 9.x
- Minimum 8GB RAM, 2 vCPU
- Static IP address with DNS
- Fully qualified domain name (FQDN)

### 1. Configure Inventory
Update `inventory/hosts`:
```ini
[idm]
idm.example.com

[idm:vars]
idm_admin_user=admin
idm_admin_password=SecurePass123
idm_dm_password=DMSecurePass456
idm_domain=example.com
idm_realm=EXAMPLE.COM
```

### 2. Configure IdM Settings
Edit `group_vars/idm.yml`:
```yaml
idm_version: "latest"
idm_admin_user: "admin"
idm_admin_password: "{{ vault_idm_admin_password }}"
idm_dm_password: "{{ vault_idm_dm_password }}"
idm_domain: "example.com"
idm_realm: "EXAMPLE.COM"
idm_setup_dns: true
idm_forwarders:
  - "8.8.8.8"
  - "8.8.4.4"
```

### 3. Deploy IdM
```bash
ansible-playbook site.yml -t idm
```

### 4. Access IdM
- **Web UI**: https://idm.example.com/ipa/ui/
- **Username**: admin
- **Password**: (from group_vars)

---

## Installation

### Detailed Installation Steps

#### Step 1: System Preparation
```bash
# Update system
yum update -y

# Install IdM packages
yum install -y ipa-server ipa-server-dns

# Configure hostname
hostnamectl set-hostname idm.example.com
hostnamectl set-hostname idm.example.com --transient

# Update /etc/hosts
cat >> /etc/hosts << EOF
192.168.1.10 idm.example.com idm
EOF

# Configure firewall
firewall-cmd --permanent --add-service=freeipa-ldap
firewall-cmd --permanent --add-service=freeipa-ldaps
firewall-cmd --permanent --add-service=dns
firewall-cmd --permanent --add-port=88/tcp
firewall-cmd --permanent --add-port=88/udp
firewall-cmd --permanent --add-port=464/tcp
firewall-cmd --permanent --add-port=464/udp
firewall-cmd --reload
```

#### Step 2: Pre-Configuration
Create configuration file at `/usr/lib/python3/site-packages/ipa/settings.yaml`:
```yaml
---
ipa:
  realm: EXAMPLE.COM
  domain: example.com
  admin_user: admin
  admin_password: "{{ vault_idm_admin_password }}"
  dm_password: "{{ vault_idm_dm_password }}"
  
  dns:
    enable: true
    forwarders:
      - 8.8.8.8
      - 8.8.4.4
  
  kerberos:
    enable: true
    kdc_ports: [88]
```

#### Step 3: Run Installation Role
```bash
# Deploy IdM via role
ansible-playbook -i inventory/hosts \
  roles/idm_integration/tasks/main.yml \
  --vault-password-file ~/.ansible/conf/vault.txt

# Or full playbook
ansible-playbook site.yml \
  -e "deployment_scenario=idm" \
  --tags idm
```

#### Step 4: Server Installation
```bash
# Run ipa-server-install
ipa-server-install \
  --realm=EXAMPLE.COM \
  --domain=example.com \
  --ds-password="DMPassword123" \
  --admin-password="AdminPassword123" \
  --hostname=idm.example.com \
  --ip-address=192.168.1.10 \
  --setup-dns \
  --allow-zone-overlap \
  --forwarder=8.8.8.8 \
  --forwarder=8.8.4.4 \
  -U
```

#### Step 5: Verification
```bash
# Check services
systemctl status ipa
systemctl status krb5kdc
systemctl status named

# Test Kerberos
kinit admin
klist

# Test LDAP
ldapsearch -x -h idm.example.com -b "cn=accounts,dc=example,dc=com"

# Test API
curl -k https://idm.example.com/ipa/session/json \
  -d "user=admin&password=AdminPassword123"
```

---

## Integration with RHIS Project

### 1. Store Credentials
```bash
# Add to group_vars/vault.yml
vault_idm_admin_password: "AdminPassword123"
vault_idm_dm_password: "DMPassword123"
vault_idm_api_token: "TOKEN..."
```

### 2. User Management
```yaml
# playbooks/manage_idm_users.yml
---
- name: Manage IdM Users
  hosts: idm
  
  vars:
    idm_users:
      - name: "jdoe"
        first_name: "John"
        last_name: "Doe"
        email: "jdoe@example.com"
        password: "{{ vault_user_password }}"
      
      - name: "msmith"
        first_name: "Mary"
        last_name: "Smith"
        email: "msmith@example.com"
        password: "{{ vault_user_password }}"
  
  tasks:
    - name: Create users
      freeipa.ansible_freeipa.ipauser:
        ipaadmin_principal: admin
        ipaadmin_password: "{{ vault_idm_admin_password }}"
        name: "{{ item.name }}"
        first: "{{ item.first_name }}"
        last: "{{ item.last_name }}"
        mail: "{{ item.email }}"
        password: "{{ item.password }}"
        state: present
      loop: "{{ idm_users }}"
```

### 3. Group Management
```yaml
# playbooks/manage_idm_groups.yml
---
- name: Manage IdM Groups
  hosts: idm
  
  vars:
    idm_groups:
      - name: "sysadmins"
        description: "System Administrators"
        members:
          - "jdoe"
          - "msmith"
      
      - name: "developers"
        description: "Development Team"
        members:
          - "dev_user1"
          - "dev_user2"
  
  tasks:
    - name: Create groups
      freeipa.ansible_freeipa.ipagroup:
        ipaadmin_principal: admin
        ipaadmin_password: "{{ vault_idm_admin_password }}"
        name: "{{ item.name }}"
        description: "{{ item.description }}"
        state: present
      loop: "{{ idm_groups }}"
    
    - name: Add members to groups
      freeipa.ansible_freeipa.ipagroup:
        ipaadmin_principal: admin
        ipaadmin_password: "{{ vault_idm_admin_password }}"
        name: "{{ item.name }}"
        user: "{{ item.members }}"
        action: member
        state: present
      loop: "{{ idm_groups }}"
```

### 4. Client Registration
```yaml
# playbooks/register_idm_client.yml
---
- name: Register Host to IdM
  hosts: all_servers
  
  tasks:
    - name: Install IdM client
      yum:
        name:
          - ipa-client
          - ipa-client-samba
        state: present
    
    - name: Discover IdM realm
      shell: |
        ipa-client-install \
          --realm=EXAMPLE.COM \
          --domain=example.com \
          --server=idm.example.com \
          --principal=admin \
          --password="{{ vault_idm_admin_password }}" \
          --unattended \
          --no-ntp \
          --no-sshd \
          --no-sudo
      args:
        creates: /etc/ipa/ca.crt
    
    - name: Verify enrollment
      shell: ipa-getkeytab -s idm.example.com -p host/{{ ansible_fqdn }}@EXAMPLE.COM -k /etc/krb5.keytab
```

---

## Update & Upgrade

### Prepare for Upgrade
```bash
# 1. Backup LDAP database
ipa-backup

# 2. Check current version
ipa --version

# 3. Check for updates
yum check-update ipa-server
```

### Upgrade Process
```bash
# Update packages
yum update -y ipa-*

# Run upgrade
ipa-server-upgrade

# Verify upgrade
ipa --version
systemctl status ipa
```

### Post-Upgrade Verification
```bash
# Check replication
ipa-replica-manage list -v

# Verify LDAP
ldapsearch -x -h idm.example.com -b "cn=schema" -s base

# Test authentication
kinit admin
klist
```

---

## Examples

### Example 1: Create User with Script
```bash
#!/bin/bash
# scripts/bash/create_idm_user.sh

USERNAME=$1
FIRST_NAME=$2
LAST_NAME=$3
EMAIL=$4
PASSWORD=$5

kinit admin <<< "$VAULT_IDM_ADMIN_PASSWORD"

ipa user-add $USERNAME \
  --first="$FIRST_NAME" \
  --last="$LAST_NAME" \
  --email="$EMAIL" \
  --password <<< "$PASSWORD"

echo "User $USERNAME created successfully"
```

### Example 2: Service Principal Creation
```yaml
---
- name: Create Service Principal for AAP
  hosts: idm
  
  tasks:
    - name: Create AAP service
      freeipa.ansible_freeipa.ipaservice:
        ipaadmin_principal: admin
        ipaadmin_password: "{{ vault_idm_admin_password }}"
        name: "HTTP/aap-controller.example.com"
        state: present
    
    - name: Create keytab for AAP
      shell: |
        ipa-getkeytab \
          -s idm.example.com \
          -p HTTP/aap-controller.example.com \
          -k /etc/ipa/aap.keytab
      
    - name: Set permissions
      file:
        path: /etc/ipa/aap.keytab
        owner: root
        group: root
        mode: '0600'
```

### Example 3: HBAC Rule Configuration
```yaml
---
- name: Configure HBAC Rules
  hosts: idm
  
  vars:
    hbac_rules:
      - name: "allow_admins_everywhere"
        servicegroups: ["all"]
        usergroups: ["sysadmins"]
        hostgroups: ["all"]
        accessruletype: allow
  
  tasks:
    - name: Create HBAC rules
      freeipa.ansible_freeipa.ipahbacrule:
        ipaadmin_principal: admin
        ipaadmin_password: "{{ vault_idm_admin_password }}"
        name: "{{ item.name }}"
        accessruletype: "{{ item.accessruletype }}"
        state: present
      loop: "{{ hbac_rules }}"
```

### Example 4: Sudo Rules
```yaml
---
- name: Configure Sudo Rules
  hosts: idm
  
  tasks:
    - name: Create sudo command group
      freeipa.ansible_freeipa.ipasuddocmdgroup:
        ipaadmin_principal: admin
        ipaadmin_password: "{{ vault_idm_admin_password }}"
        name: "admin_cmds"
        description: "Administrative commands"
        state: present
    
    - name: Add commands to group
      freeipa.ansible_freeipa.ipasuddocmd:
        ipaadmin_principal: admin
        ipaadmin_password: "{{ vault_idm_admin_password }}"
        sudocmd: "/usr/bin/systemctl"
        sudocmdgroup: "admin_cmds"
        state: present
    
    - name: Create sudo rule
      freeipa.ansible_freeipa.ipasudorule:
        ipaadmin_principal: admin
        ipaadmin_password: "{{ vault_idm_admin_password }}"
        name: "admin_sudo"
        usergroup: "sysadmins"
        host: "all"
        sudocmdgroup: "admin_cmds"
        state: present
```

### Example 5: DNS Zone Management
```python
#!/usr/bin/env python3
# scripts/python/manage_idm_dns.py

from ipalib import api
import sys

class IdMDNS:
    def __init__(self, server, username, password):
        self.api = api
        self.api.connect(
            ldap_uri=f"ldap://{server}",
            bind_dn=f"uid={username},cn=users,cn=accounts,dc=example,dc=com",
            bind_pw=password
        )
    
    def create_zone(self, name):
        """Create DNS zone"""
        return self.api.dns_zone_add(name=name)
    
    def add_record(self, zone_name, name, rrtype, values):
        """Add DNS record"""
        return self.api.dns_record_add(
            zone_name,
            name,
            rrtype=rrtype,
            **{rrtype.lower(): values}
        )
    
    def list_zones(self):
        """List all zones"""
        result = self.api.dns_zone_find()
        return result['result']

# Usage
dns = IdMDNS("idm.example.com", "admin", "password")
zones = dns.list_zones()
print("Available DNS Zones:")
for zone in zones:
    print(f"  - {zone['idnszonename']}")
```

---

## Troubleshooting

### Issue: Kerberos Authentication Fails
```bash
# Check Kerberos configuration
cat /etc/krb5.conf

# Clear credential cache
kdestroy
kinit admin

# Check KDC logs
tail -f /var/log/krb5kdc.log
```

### Issue: LDAP Directory Connection Fails
```bash
# Check LDAP service
systemctl status dirsrv@example-com

# Verify LDAP connectivity
ldapsearch -x -h localhost -b "dc=example,dc=com" -s base

# Check directory logs
tail -f /var/log/dirsrv/slapd-example-com/access
```

### Issue: DNS Resolution Not Working
```bash
# Verify named service
systemctl status named

# Test DNS lookup
nslookup idm.example.com localhost
dig @localhost idm.example.com

# Check DNS logs
tail -f /var/log/named/query.log
```

---

## Additional Resources

- [IdM Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_identity_management/)
- [FreeIPA Project](https://www.freeipa.org/)
- [Ansible FreeIPA Roles](https://github.com/freeipa/ansible-freeipa)
- [RHIS Project Guide](../README.md)
- [Related: Satellite Integration](../satellite/README.md)

---

**Last Updated:** January 2026
**Supported Versions:** IdM 4.9+ (RHEL 9 based)
**RHIS Compatibility:** All platforms (Libvirt, AWS, Azure, VMware, Nutanix)
