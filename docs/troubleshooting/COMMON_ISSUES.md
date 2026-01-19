# Troubleshooting - Common Issues

Solutions to common RHIS deployment and operational issues.

## Installation Issues

### Problem: Ansible Not Found

**Error:** `bash: ansible: command not found`

**Solution:**
```bash
pip install ansible
# or
yum install ansible-core
```

### Problem: Python Version Incompatibility

**Error:** `python 3.8 is not supported by Ansible 2.9+`

**Solution:**
```bash
# Use Python 3.9+
python3.11 -m pip install ansible
# or update system Python
yum install python311
```

### Problem: SELinux Denials

**Error:** `AVC audit` messages in logs

**Solutions:**
```bash
# Temporarily set to permissive
setenforce 0

# Or permanently disable (not recommended for production)
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
```

### Problem: Out of Disk Space

**Error:** `No space left on device`

**Solution:**
```bash
# Check disk usage
df -h

# Clean up old deployments
rm -rf /var/log/deployment.*.log*

# Or extend partition (if using LVM)
lvextend -L +100G /dev/vg0/lv_root
```

## Deployment Issues

### Problem: Network Unreachable

**Error:** `Host unreachable` or connection timeouts

**Solutions:**
```bash
# Check network connectivity
ping -c 1 gateway-ip

# Verify DNS
nslookup example.com

# Check firewall
firewall-cmd --list-all
firewall-cmd --add-port=443/tcp
```

### Problem: Insufficient Memory

**Error:** `Killed` or `Out of memory` messages

**Solution:**
- Ensure 64GB+ RAM available
- Stop non-essential services
- Increase swap space:

```bash
dd if=/dev/zero of=/swapfile bs=1G count=16
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

### Problem: SSH Key Issues

**Error:** `Permission denied (publickey)`

**Solution:**
```bash
# Ensure proper permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Add key to agent
ssh-add ~/.ssh/id_rsa
```

## Product-Specific Issues

### Satellite Issues

```bash
# Check Satellite service status
foreman-service-status

# View logs
tail -f /var/log/foreman/production.log

# Restart services
hammer -u admin -p <password> service restart
```

### AAP Issues

```bash
# Check AAP status
podman ps | grep automation

# View logs
podman logs -f automation-platform

# Restart AAP
systemctl restart aap
```

### IdM Issues

```bash
# Check IdM service status
ipactl status

# View logs
tail -f /var/log/dirsrv/slapd-*/access

# Restart IdM
ipactl restart
```

## Performance Issues

### Slow Playbook Execution

```bash
# Enable profiling
ANSIBLE_PROFILE_TASKS=1 ansible-playbook redhat_management-site.yml

# Check task timing
ansible-playbook redhat_management-site.yml -v | grep duration
```

### High CPU Usage

```bash
# Monitor processes
top -b -n 1 | head -20

# Check ansible processes
ps aux | grep ansible
```

## Getting Help

### Check Logs

```bash
# RHIS deployment logs
tail -f /var/log/rhis-deployment.log

# System logs
journalctl -xe

# Ansible playbook logs
tail -f logs/deployment.log
```

### Enable Debug Verbosity

```bash
# Ansible debug output
ansible-playbook redhat_management-site.yml -vvv

# Bash debug
bash -x scripts/setup/RHIS-installer.sh
```

### Collect Debug Information

```bash
# Create debug package
ansible all -m setup -a "filter=ansible_*" > system-info.txt
journalctl > system-logs.txt
tar czf debug-bundle.tar.gz system-info.txt system-logs.txt
```

---

If issues persist, see [Support](SUPPORT.md) for escalation procedures.
