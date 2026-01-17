# IdM 3.0 Deployment Guide

Complete guide for deploying Red Hat Identity Management 3.0.

## Prerequisites

- RHEL 8.6+ or RHEL 9.0+
- 4 vCPU, 8 GB RAM minimum (16 GB for production)
- 20 GB disk space
- Fully qualified domain name (FQDN)
- Static IP address
- Time synchronization (NTP/Chrony)

## Pre-Deployment

### 1. System Preparation

```bash
# Update system
sudo yum update -y

# Set hostname
sudo hostnamectl set-hostname idm.example.com

# Configure /etc/hosts
echo "192.168.1.10  idm.example.com  idm" | sudo tee -a /etc/hosts

# Sync time
sudo timedatectl set-ntp true
sudo systemctl enable chronyd
sudo systemctl start chronyd
```

### 2. Install IdM Packages

```bash
# Install IdM server
sudo yum install -y ipa-server ipa-server-dns

# Install optional components
sudo yum install -y \
  ipa-server-trust-ad \
  bind \
  bind-utils \
  krb5-workstation
```

### 3. Firewall Configuration

```bash
# Enable IdM services
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --add-service=kerberos --permanent
sudo firewall-cmd --add-service=kpasswd --permanent
sudo firewall-cmd --add-service=ldap --permanent
sudo firewall-cmd --add-service=ldaps --permanent
sudo firewall-cmd --reload
```

## Installation

### 1. Run IdM Installer

```bash
# Start interactive installer
sudo ipa-server-install

# Or with options
sudo ipa-server-install \
  --realm EXAMPLE.COM \
  --domain example.com \
  --ds-password DirServerPassword123! \
  --admin-password AdminPassword123! \
  --hostname idm.example.com \
  --ip-address 192.168.1.10 \
  --setup-dns \
  --allow-zone-overlap \
  --unattended
```

### 2. Verify Installation

```bash
# Check IdM status
sudo ipactl status

# Verify Kerberos
kinit admin
klist

# Check directory server
ldapsearch -x -h localhost -b "dc=example,dc=com" -s base
```

## Initial Configuration

### 1. Login to IdM Web UI

- URL: `https://idm.example.com/`
- Username: `admin`
- Password: Set during installation

### 2. Create Users

```bash
# Via CLI
ipa user-add john \
  --first "John" \
  --last "Doe" \
  --email john@example.com \
  --phone "+1-555-0100" \
  --password

# Verify
ipa user-find john
```

### 3. Create User Groups

```bash
# Create group
ipa group-add sysadmins \
  --desc "System Administrators"

# Add users to group
ipa group-add-member sysadmins \
  --users john
```

### 4. Create Host Groups

For organizing managed systems:

```bash
# Create host group
ipa hostgroup-add production \
  --desc "Production Servers"

# Create another
ipa hostgroup-add development \
  --desc "Development Servers"
```

## Kerberos Configuration

### 1. Kerberize Services

Set up Kerberos for services:

```bash
# Create service principal
ipa service-add HTTP/aap.example.com@EXAMPLE.COM

# Create service principal for Satellite
ipa service-add HTTP/satellite.example.com@EXAMPLE.COM
```

### 2. Generate Keytabs

```bash
# For AAP
ipa-getkeytab \
  -s idm.example.com \
  -p HTTP/aap.example.com \
  -k /etc/aap/aap.keytab

# For Satellite
ipa-getkeytab \
  -s idm.example.com \
  -p HTTP/satellite.example.com \
  -k /etc/satellite/satellite.keytab
```

## LDAP Configuration

### 1. LDAP Access

IdM provides LDAP interface for third-party apps:

```bash
# LDAP server
ldaps://idm.example.com:636

# Search base
cn=users,cn=accounts,dc=example,dc=com

# User DN format
uid=<username>,cn=users,cn=accounts,dc=example,dc=com
```

### 2. Allow LDAP Binds

```bash
# For applications needing to bind
ipa user-add serviceaccount \
  --first "Service" \
  --last "Account" \
  --password
```

## Integration with AAP

### 1. Configure AAP for LDAP

AAP server authentication settings:

```
Settings → Authentication → LDAP

AUTH_LDAP_SERVER_URI = ldaps://idm.example.com:636
AUTH_LDAP_BIND_DN = uid=serviceaccount,cn=users,cn=accounts,dc=example,dc=com
AUTH_LDAP_BIND_PASSWORD = <serviceaccount-password>
AUTH_LDAP_USER_SEARCH_BASE = cn=users,cn=accounts,dc=example,dc=com
AUTH_LDAP_USER_ATTR_MAP = {
  "first_name": "givenName",
  "last_name": "sn",
  "email": "mail"
}
```

### 2. Map IdM Groups to AAP Teams

In AAP:

```
Settings → Authentication → LDAP Team Maps

[
  {
    "ldapgrouptype": "cn",
    "remove": false
  }
]
```

## Integration with Satellite

### 1. Configure Satellite for LDAP

**Settings** → **Authentication** → **LDAP**

```yaml
ldap_url: ldaps://idm.example.com:636
ldap_base: cn=users,cn=accounts,dc=example,dc=com
ldap_user_attr: uid
ldap_group_attr: cn
ldap_group_base: cn=groups,cn=accounts,dc=example,dc=com
ldap_tls: true
```

### 2. Create Admin User

```bash
# Create RHIS Admin group in IdM
ipa group-add rhis-admins \
  --desc "RHIS Administrators"

# Add user to admin group
ipa group-add-member rhis-admins --users john

# In Satellite, map this group to admin role
```

## Replication

### Setup IdM Replica

For HA and redundancy:

```bash
# On replica server
sudo yum install -y ipa-server ipa-server-dns

# Prepare replica
sudo ipa-replica-prepare \
  --ip-address 192.168.1.11 \
  replica.example.com

# Install replica
sudo ipa-replica-install \
  replica-info-replica.example.com.gpg
```

### Verify Replication

```bash
# Check replication status
sudo ipa-replica-manage list
sudo ipa-replica-manage list -r

# Monitor replication
sudo ipa-replica-manage list -r --verbose
```

## Certificate Management

### 1. View Certificates

```bash
# List all certificates
ipa cert-find

# Check specific certificate
ipa cert-show --serial <serial_number>
```

### 2. Issue User Certificates

For client authentication:

```bash
# Generate CSR
openssl req -new -key user.key -out user.csr

# Issue certificate via IdM
ipa cert-request user.csr
```

## Client Configuration

### 1. Join Systems to IdM

On client systems:

```bash
# Install IdM client packages
sudo yum install -y ipa-client ipa-client-samba

# Run enrollment
sudo ipa-client-install \
  --server idm.example.com \
  --domain example.com \
  --realm EXAMPLE.COM \
  --principal admin \
  --password <admin-password> \
  --unattended
```

### 2. Verify Client Enrollment

```bash
# Check enrollment
sudo ipa-client-automount --help

# Test LDAP connectivity
ldapwhoami -H ldaps://idm.example.com:636 \
  -D "uid=admin,cn=users,cn=accounts,dc=example,dc=com" \
  -w <password>
```

## Maintenance

### Backup

```bash
# Full backup
sudo ipa-backup --verbose --logs

# Backup location
/var/lib/ipa/backup/
```

### Restore

```bash
# List backups
sudo ipa-backup-restore -l

# Restore backup
sudo ipa-backup-restore <backup-dir>
```

### Update IdM

```bash
# Check for updates
sudo yum check-update ipa-server

# Apply updates
sudo yum update -y ipa-server

# Run upgrade
sudo ipa-server-upgrade
```

## Monitoring

### Check Services

```bash
# All services running?
sudo ipactl status

# Individual service status
sudo systemctl status ipa

# Check Kerberos KDC
sudo systemctl status krb5kdc kadmin
```

### Check Logs

```bash
# IdM logs
sudo tail -100f /var/log/ipa-server-install.log
sudo tail -100f /var/log/dirsrv/slapd-EXAMPLE_COM.log

# Kerberos logs
sudo tail -100f /var/log/krb5kdc.log
sudo tail -100f /var/log/kadmind.log
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| LDAP bind fails | Check serviceaccount exists: `ipa user-find serviceaccount` |
| DNS resolution fails | Check /etc/resolv.conf, verify IdM DNS is master |
| Certificate expired | Renew: `sudo ipa-certupdate` |
| Replication failed | Check network, verify ports open, restart dirsrv |
| Time sync issues | Run `sudo chronyc makestep` |

### Reset Admin Password

```bash
# Direct directory update
sudo ldappasswd -x -D "cn=Directory Manager" \
  -W "uid=admin,cn=users,cn=accounts,dc=example,dc=com"
```

## References

- [IdM 3.0 Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/installing_identity_management/)
- [IdM Administration](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/managing_identity_management/)
- [IdM Configuration](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/system-level_authentication_management/)
