# SETUP_GUIDE.md - Complete Setup Instructions for LVM Automation

## **Complete Setup Guide for LVM Automation with Email Notifications**

### **1. Prerequisites**

#### System Requirements:
- RHEL 8 or RHEL 9 target servers
- Nutanix cluster with Prism Central access
- Ansible control node (can be one of the RHEL servers)
- SMTP server or email service access

#### Software Requirements:
```bash
# Install Ansible and Event Driven Ansible
sudo dnf install ansible-core python3-pip -y
pip3 install ansible-rulebook asyncio aiohttp

# Or using RHEL subscription:
sudo subscription-manager repos --enable=ansible-automation-platform-2.4-for-rhel-9-x86_64-rpms
sudo dnf install ansible-core ansible-navigator -y
```

### **2. Quick Setup**

```bash
# Clone/download the project
cd /path/to/Add_LVM_to_System

# Run the automated setup
chmod +x setup_lvm_automation.sh
./setup_lvm_automation.sh
```

### **3. Configuration Steps**

#### A. Edit Inventory Configuration
```bash
vi inventory.yml
```

Configure your servers and settings:
```yaml
all:
 children:
 rhel_servers:
 hosts:
 rhel8-server:
 ansible_host: YOUR_SERVER_IP
 ansible_user: YOUR_ANSIBLE_USER
 ansible_ssh_private_key_file: ~/.ssh/id_rsa
 vars:
 # Nutanix settings
 nutanix_host: "YOUR_PRISM_CENTRAL_IP"
 nutanix_username: "YOUR_NUTANIX_USER"
 nutanix_password: "{{ vault_nutanix_password }}"
 storage_container_uuid: "{{ vault_storage_container_uuid }}"
 
 # Email settings
 admin_email: "YOUR_EMAIL@company.com"
 
 # Optional: Custom SMTP (if not using localhost)
 # mail_smtp_host: "smtp.company.com"
 # mail_smtp_port: 587
 # mail_smtp_username: "{{ vault_smtp_username }}"
 # mail_smtp_password: "{{ vault_smtp_password }}"
 # mail_from: "lvm-automation@company.com"
 # mail_use_tls: true
```

#### B. Create Vault File for Secrets
```bash
# Create vault file
cp vault_example.yml vault.yml
vi vault.yml

# Add your secrets:
---
vault_nutanix_password: "your_nutanix_password"
vault_storage_container_uuid: "your_storage_container_uuid"
vault_smtp_username: "your_smtp_username" # if using custom SMTP
vault_smtp_password: "your_smtp_password" # if using custom SMTP

# Encrypt the vault
ansible-vault encrypt vault.yml
```

#### C. Setup SMTP Server (Choose One Option)

**Option 1: Use External SMTP Service (Recommended)**
```yaml
# In inventory.yml
mail_smtp_host: "smtp.gmail.com" # Gmail
mail_smtp_port: 587
mail_smtp_username: "{{ vault_smtp_username }}"
mail_smtp_password: "{{ vault_smtp_password }}"
mail_use_tls: true
```

**Option 2: Install Local Postfix (Simple)**
```bash
# On the Ansible control node
sudo dnf install postfix -y
sudo systemctl enable --now postfix

# Configure basic relay (edit /etc/postfix/main.cf)
sudo postconf -e "relayhost = [your.mail.server]:587"
sudo postconf -e "smtp_use_tls = yes"
sudo systemctl restart postfix
```

**Option 3: Use Mail Relay Service**
```bash
# Configure your organization's mail relay
mail_smtp_host: "mailrelay.company.com"
mail_smtp_port: 25
# Usually no authentication needed for internal relays
```

### **4. Testing**

#### Test Collections Installation
```bash
ansible-galaxy collection list | grep -E "(community.general|nutanix.ncp)"
```

#### Test Email Configuration
```bash
# Run comprehensive email test
./test_email_notifications.sh

# Quick manual test
ansible localhost -m community.general.mail -a "to=test@company.com subject='Test' body='Test message'"
```

#### Test Nutanix Connectivity
```bash
# Test Nutanix API access
ansible-playbook nutanix_disk_creation.yml --check -e "vm_name=test new_disk_size_gb=1"
```

#### Test LVM Detection
```bash
# Test system inspection
ansible your_rhel_server -m shell -a "vgdisplay && lvdisplay && df -h"
```

### **5. Deployment**

#### Start Event Driven Ansible
```bash
# Start the EDA service
./start_eda.sh

# Verify it's running
ps aux | grep ansible-rulebook
```

#### Install Monitoring on Target Servers
```bash
# On each RHEL server, install the monitoring cron job
ansible rhel_servers -m copy -a "src=disk_usage_monitor.yml dest=/opt/lvm_monitor.yml"
ansible rhel_servers -m cron -a "name='LVM Disk Usage Monitor' minute='*/5' job='ansible-playbook /opt/lvm_monitor.yml'"
```

#### Test End-to-End
```bash
# Create a test scenario (on target server)
sudo dd if=/dev/zero of=/testfile bs=1M count=1000 # Create large file
df -h # Check if any filesystem is near 90%

# Monitor EDA logs
tail -f /var/log/ansible-rulebook.log # or wherever EDA logs go
```

### **6. Production Considerations**

#### Security
- Use ansible-vault for all passwords
- Implement proper firewall rules
- Use dedicated service accounts
- Enable HTTPS for webhooks in production

#### Monitoring
- Set up log rotation for EDA logs
- Monitor webhook endpoint availability
- Set up alerting for failed automation

#### Backup
- Backup inventory and vault files
- Document your Nutanix storage container UUIDs
- Test restore procedures

### **7. Troubleshooting**

#### Common Issues

1. **Email not sending**
 ```bash
 # Check SMTP connectivity
 telnet your.smtp.server 25
 
 # Test with simple mail command
 echo "Test" | mail -s "Test Subject" admin@company.com
 ```

2. **Nutanix API errors**
 ```bash
 # Verify credentials and connectivity
 curl -k -u username:password https://prism-central-ip:9440/api/nutanix/v3/clusters
 ```

3. **Webhook not responding**
 ```bash
 # Check EDA process
 sudo systemctl status ansible-rulebook # if using systemd
 
 # Test webhook manually
 curl -X POST http://localhost:5000/webhook -d '{"test":"data"}'
 ```

4. **LVM operations failing**
 ```bash
 # Check LVM status
 sudo vgdisplay
 sudo lvdisplay
 sudo pvdisplay
 
 # Check system logs
 sudo journalctl -xe | grep -i lvm
 ```

### **8. Support and Maintenance**

#### Regular Tasks
- Monitor disk usage trends
- Review automation logs weekly 
- Test email notifications monthly
- Update Ansible collections quarterly

#### Log Locations
- EDA logs: Check systemd journal or configured log file
- Ansible logs: `/tmp/ansible.log` (if configured)
- System logs: `/var/log/messages`
- Email logs: `/var/log/maillog`

---

## **Quick Start Checklist**

- [ ] Install Ansible and EDA
- [ ] Run `./setup_lvm_automation.sh`
- [ ] Configure `inventory.yml` with your servers
- [ ] Create and encrypt `vault.yml` with secrets
- [ ] Configure SMTP settings 
- [ ] Test email: `./test_email_notifications.sh`
- [ ] Test Nutanix connectivity
- [ ] Start EDA: `./start_eda.sh`
- [ ] Install monitoring cron jobs on target servers
- [ ] Test with real disk usage scenario

**Your automated LVM management system is ready!** 