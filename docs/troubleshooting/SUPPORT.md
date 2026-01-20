# Troubleshooting - Support and Escalation

Guide for getting ansible_dev_node_support and escalating issues in RHIS deployments.

## Support Resources

### Red Hat Support Portal

**Access:** https://access.redhat.com/

Features:
- Open ansible_dev_node_support tickets
- Search knowledgebase
- Download patches and errata
- View system status

**Entitlements Required:**
- Red Hat Subscription
- Support level (Standard, Premium, or Mission Critical)

### Red Hat Product Documentation

**Key Resources:**
- [Satellite 6.18 Documentation](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.18/)
- [AAP 2.6 Documentation](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6/)
- [IdM 3.0 Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/)
- [RHEL Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/)

### Community Resources

**Forums:**
- [Red Hat Community](https://www.redhat.com/en/open-source/communities)
- [Ansible Community](https://www.ansible.com/community)
- Stack Overflow (tag: ansible, scenario_satellite, etc.)

**Chat:**
- IRC: Freenode #ansible
- Matrix/Slack communities

## Issue Diagnosis

### Data Collection

Before opening ticket, collect:

```bash
#!/bin/bash
# Collect diagnostic information

HOSTNAME=$(hostname)
DATE=$(date +%Y%m%d-%H%M%S)
OUTPUT_DIR="rhis-diagnostics-${HOSTNAME}-${DATE}"

mkdir -p "${OUTPUT_DIR}"

# System information
echo "=== System Information ===" > "${OUTPUT_DIR}/system-info.txt"
uname -a >> "${OUTPUT_DIR}/system-info.txt"
hostnamectl status >> "${OUTPUT_DIR}/system-info.txt"
timedatectl status >> "${OUTPUT_DIR}/system-info.txt"
df -h >> "${OUTPUT_DIR}/system-info.txt"
free -h >> "${OUTPUT_DIR}/system-info.txt"

# Network information
echo "=== Network Configuration ===" > "${OUTPUT_DIR}/network-info.txt"
ip addr >> "${OUTPUT_DIR}/network-info.txt"
ip route >> "${OUTPUT_DIR}/network-info.txt"
netstat -tlnp >> "${OUTPUT_DIR}/network-info.txt"

# Firewall information
echo "=== Firewall Status ===" > "${OUTPUT_DIR}/firewall-info.txt"
firewall-cmd --list-all >> "${OUTPUT_DIR}/firewall-info.txt"

# Service logs
sudo journalctl -n 100 > "${OUTPUT_DIR}/system-logs.txt"
sudo journalctl -xe > "${OUTPUT_DIR}/system-errors.txt"

# Application logs (if applicable)
if command -v foreman &>/dev/null; then
  sudo tail -100 /var/log/foreman/production.log > "${OUTPUT_DIR}/foreman.log"
fi

if command -v ipactl &>/dev/null; then
  sudo tail -100 /var/log/dirsrv/slapd-*.log > "${OUTPUT_DIR}/idm.log" 2>/dev/null || true
fi

# Compress diagnostics
tar czf "${OUTPUT_DIR}.tar.gz" "${OUTPUT_DIR}"
echo "Diagnostics saved to ${OUTPUT_DIR}.tar.gz"
```

### Collect Logs

**AAP Logs:**
```bash
# Container logs
docker logs aap-controller-1 > aap-controller.log
docker logs aap-postgres-1 > aap-postgres.log

# Application logs
docker exec aap-controller-1 tail -200 /var/log/awx/dispatcher.log
```

**Satellite Logs:**
```bash
# Foreman logs
sudo tail -200 /var/log/foreman/production.log
sudo tail -200 /var/log/tomcat/catalina.out
sudo tail -200 /var/log/httpd/access_ssl_log
sudo tail -200 /var/log/httpd/error_ssl_log

# Database logs
sudo tail -200 /var/log/postgresql/postgresql.log
```

**IdM Logs:**
```bash
# Directory server
sudo tail -200 /var/log/dirsrv/slapd-EXAMPLE_COM/errors

# Kerberos
sudo tail -200 /var/log/krb5kdc.log
sudo tail -200 /var/log/kadmind.log
```

## Opening a Support Ticket

### Required Information

When opening a ticket with Red Hat, provide:

```
1. Problem Summary
   - Issue description
   - When first occurred
   - Impact on operations

2. Environment Details
   - RHEL version
   - Product versions (AAP, Satellite, IdM)
   - Deployment type (single node, HA, cloud, etc.)
   - Number of managed systems

3. Error Messages
   - Exact error text
   - Where error appears (UI, logs, CLI)
   - Steps to reproduce

4. Recent Changes
   - Updates or patches applied
   - Configuration changes
   - Infrastructure changes

5. Diagnostic Data
   - Diagnostic bundle (created above)
   - Relevant log files
   - Database status output
   - Network diagnostic output
```

### Severity Levels

```
Severity 1 (Critical)
- Production system completely unavailable
- Data loss or corruption
- Security breach
- Response time: 1 hour
- Escalation: Immediate

Severity 2 (High)
- Major functionality unavailable
- Significant performance degradation
- Workaround available
- Response time: 4 hours
- Escalation: 8 hours if not resolved

Severity 3 (Medium)
- Minor functionality unavailable
- Low impact on operations
- Workaround available
- Response time: 8 hours
- Escalation: 24 hours if not resolved

Severity 4 (Low)
- Enhancement request
- Documentation clarification
- No workaround needed
- Response time: 24 hours
```

### Open Ticket via Portal

1. Navigate to https://access.redhat.com/ansible_dev_node_support/cases/
2. Click "Create a Case"
3. Fill in:
   - Product: Select appropriate product
   - Severity: Choose level
   - Summary: Brief description
   - Description: Full details
   - Attachments: Diagnostic bundle

4. Click "Create Case"
5. Note case number for reference

## Self-Service Troubleshooting

### Search Knowledgebase

Before opening ticket, search existing solutions:

```bash
# Common search terms
"AAP database connection refused"
"Satellite inventory sync timeout"
"IdM LDAP bind failure"
"Ansible job execution error"
```

### Common Solutions Database

```
Article ID: Search Term
BZ#1234567: AAP high memory usage
KCS#1122334: Satellite repository sync slow
KCS#1556677: IdM replication conflict
```

## Escalation Process

### Escalation Path

```
1. Self-Service
   > Search knowledgebase
       > Review documentation
           > Try suggested solutions

2. Support Portal
   > Create ansible_dev_node_support case
       > Initial response (24 hours)
           > Troubleshooting (48 hours)
                > Engineering engagement
                    > Resolution or workaround

3. Priority Escalation (if SLA not met)
   > Request manager escalation
       > Request TAM (Technical Account Manager)
           > Request executive escalation
```

### Escalation Contacts

**Standard Support:**
- Support Portal: cases.redhat.com
- Email: ansible_dev_node_support@redhat.com
- Phone: 1-888-733-8423

**Premium Support:**
- Direct phone line
- Email with priority routing
- TAM access
- Phone: (check your Red Hat account)

**Mission Critical:**
- Dedicated TAM
- 15-minute response time
- Conference bridge access
- Phone: (check your Red Hat account)

## Remote Support Sessions

### Grant Red Hat Remote Access

For direct troubleshooting:

```bash
# Install Red Hat Access Insights
sudo yum install -y insights-client

# Register system
sudo insights-client --register

# Enable remote ansible_dev_node_support
sudo insights-client --collector

# Authorize Red Hat ansible_dev_node_support
# Via: https://access.redhat.com/insights/
```

### VPN/SSH Access

If remote ansible_dev_node_support needed:

```bash
# Create ansible_dev_node_support user
sudo useradd -m -s /bin/bash redhat-ansible_dev_node_support
sudo usermod -aG wheel redhat-ansible_dev_node_support

# Generate key
ssh-keygen -t rsa -b 4096 -f /home/redhat-ansible_dev_node_support/.ssh/id_rsa

# Configure sudo for specific commands only
# /etc/sudoers.d/redhat-ansible_dev_node_support
# redhat-ansible_dev_node_support ALL=(ALL) NOPASSWD: /usr/bin/tail, /usr/bin/less, etc.

# Red Hat ansible_dev_node_support team connects and performs diagnostics
```

## Common Escalation Triggers

### Auto-Escalate If:

```
- Issue not resolved within SLA
- Multiple ansible_dev_node_support tickets on same issue
- Workaround impacts operations
- Issue blocks critical business process
- Security implications identified
- Database corruption suspected
- Data loss risk identified
```

### Manual Escalation Checklist

```bash
# Before escalating, verify:
[ ] All troubleshooting steps completed
[ ] All logs collected
[ ] Configuration verified correct
[ ] Services restarted successfully
[ ] System resources available
[ ] Network connectivity confirmed
[ ] DNS resolving correctly
[ ] Firewall rules allowing traffic
[ ] Time synchronization verified
[ ] Subscription valid and active
```

## Communication Best Practices

### Ticket Updates

```
Good update:
"Applied kernel update following KCS#1234567.
Services restarted successfully.
Error still occurs when running playbook X.
New error message: [exact error text]
Next step: Check database logs"

Poor update:
"Still not working. Help!"
```

### Include Context

Always provide:
- Exact commands run
- Exact output and errors
- Steps taken so far
- What worked / what didn't
- Environment changes since last working

### Document Resolution

When issue is resolved:
```
Root Cause: [what was wrong]
Solution: [steps to fix]
Time to Resolution: [hours/days]
Prevention: [how to avoid in future]
```

## Training and Certification

### Red Hat Training

- Red Hat Certified Systems Administrator (RHCSA)
- Red Hat Certified Engineer (RHCE)
- Red Hat Certified Specialist in Ansible Automation
- Red Hat Certified Specialist in Satellite

**Benefits:**
- Faster issue resolution
- Deeper product knowledge
- Reduced ansible_dev_node_support ticket frequency

### Advanced Support Features

With certification/training:
- Access to advanced training materials
- Priority queue in ansible_dev_node_support portal
- Advanced troubleshooting guides
- Early access to product releases

---

See [Common Issues](./COMMON_ISSUES.md) for quick solutions and [Troubleshooting](.) for general troubleshooting guides.
