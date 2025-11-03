# Quick Start Guide - LVM Auto-Extension

Get up and running in **15 minutes**! [FAST]

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] Python 3.8+ installed
- [ ] Ansible 2.9+ installed 
- [ ] Access to Red Hat Automation Hub (token)
- [ ] AAP 2.5 instance with admin access
- [ ] Git installed
- [ ] SSH access to target servers

## Step-by-Step Setup

### Step 1: Clone and Navigate (1 min)

```bash
git clone https://github.com/your-org/lvm-automation.git
cd lvm-automation
```

### Step 2: Run Project Manager (1 min)

```bash
python aap_lvm_manager.py
```

You'll see the main menu:
```
╔═══════════════════════════════════════════╗
║ LVM Auto-Extension Project Manager ║
╚═══════════════════════════════════════════╝

 1) Analysis & Reporting
 2) Backup & Restore
 3) Cleanup & Maintenance
 4) Consolidation
 5) Environment Setup
 6) Security & Vault Management
 7) Setup & Initialization
 8) Testing & Validation
 9) Dry-Run / Check Mode

 D) Enable dry-run mode
 0) Exit

Choice [0-9,D]:
```

### Step 3: Configure Environment (3 min)

```
1. Press 5 (Environment Setup)
2. Press 7 (Complete setup wizard)
```

**You'll be prompted for:**

1. **Red Hat Automation Hub Token** (required)
 - Get it from: https://console.redhat.com/ansible/automation-hub/token
 - Paste when prompted

2. **GitHub credentials** (optional)
 - Username
 - Personal Access Token
 - Repository URL

3. **ServiceNow** (optional)
 - Instance name (e.g., dev12345)
 - Username
 - Password

4. **Nutanix** (optional)
 - Prism Central host/IP
 - Port (default: 9440)
 - Username
 - Password

**Tip**: Press Enter to skip optional items.

### Step 4: Create Project Structure (2 min)

```
1. Press 0 to return to main menu
2. Press 7 (Setup & Initialization)
3. Press 14 (Create ALL components)
```

This creates:
- [DONE] All 6 Ansible roles
- [DONE] All playbooks (monitoring, extension, ServiceNow)
- [DONE] EDA rulebooks (webhook, Splunk)
- [DONE] Scripts (start_eda.sh, test_webhook.sh)
- [DONE] Configuration files
- [DONE] README, LICENSE

You'll see:
```
━━━ Creating Roles ━━━
[OK] Created servicenow_ticket_management
[OK] Created lvm_smart_extend
...

━━━ Creating Playbooks ━━━
[OK] Created disk_usage_monitor.yml
[OK] Created extend_lvm.yml
...

╔═════════════════════════════════════════╗
║ All Components Created Successfully ║
╚═════════════════════════════════════════╝
```

### Step 5: Collect Credentials (3 min)

```
1. Press 0 to return to main menu
2. Press 7 (Setup & Initialization)
3. Press 12 (Setup credentials)
```

This creates the credential collection system.

**Now run the playbook:**

```bash
ansible-playbook playbooks/setup_credentials.yml --ask-vault-pass
```

**Enter when prompted:**
- Vault password (choose a strong password, save it!)
- ServiceNow instance
- ServiceNow username/password
- Nutanix host/username/password
- AAP Controller URL/username/password
- Splunk HEC URL/token

**The credentials are encrypted and saved to `vault/credentials.yml`**

### Step 6: Configure AAP 2.5 (5 min)

```bash
ansible-playbook playbooks/configure_aap.yml --ask-vault-pass
```

This configures:
- [DONE] Custom credential types (Nutanix, Splunk)
- [DONE] Credentials (ServiceNow, Nutanix, Splunk)
- [DONE] Project from Git
- [DONE] Dynamic inventories (ServiceNow, Nutanix)
- [DONE] Job templates (Monitor, Extend, Ticket)
- [DONE] Workflow template
- [DONE] EDA Controller configuration
- [DONE] Splunk rulebook activation

**Output:**
```
╔═══════════════════════════════════════════════════════╗
║ AAP 2.5 Configuration Complete ║
╚═══════════════════════════════════════════════════════╝

[OK] Credentials created (ServiceNow, Nutanix)
[OK] Project created from Git
[OK] Dynamic inventories configured
[OK] Job templates created
[OK] Workflow template created
[OK] EDA Controller configured

Access your AAP: https://aap.example.com
```

## Quick Test

### Test 1: Manual Disk Monitoring

```bash
ansible-playbook playbooks/disk_usage_monitor.yml \
 -i inventory/hosts \
 -e "threshold_percent=80"
```

### Test 2: Webhook (if running EDA locally)

```bash
./test_webhook.sh
```

### Test 3: AAP Workflow

1. Log into AAP: `https://your-aap-host`
2. Navigate to: **Templates → LVM Auto-Extension Workflow**
3. Click **Launch**
4. Fill in survey:
 - Target Host: `server01`
 - Mount Point: `/`
5. Click **Launch**

## Common First-Time Issues

### Issue: "Vault password not provided"

**Fix:**
```bash
# Create password file
echo "your_vault_password" >.vault_pass
chmod 600.vault_pass

# Use it
ansible-playbook playbooks/extend_lvm.yml --vault-password-file.vault_pass
```

### Issue: "No hosts matched"

**Fix:**
```bash
# Add servers to inventory
echo "192.168.1.100" >> inventory/hosts

# Or use dynamic inventory
export NUTANIX_HOST=prism-central.example.com
export NUTANIX_USER=admin
export NUTANIX_PASS=password
python inventory/nutanix_dynamic.py
```

### Issue: "Collection not found"

**Fix:**
```bash
# Install collections
ansible-galaxy collection install -r requirements.yml
```

## Next Steps

Now that you're set up:

1. **Read the docs**: Check `DOC.md` for detailed information
2. **Customize thresholds**: Edit `vault/credentials.yml` (remember to re-encrypt!)
3. **Add your servers**: Update `inventory/hosts`
4. **Test EDA**: Start the EDA controller with `./start_eda.sh`
5. **Monitor**: Check AAP job output and ServiceNow tickets

## Cheat Sheet

### Common Commands

```bash
# Project Manager
python aap_lvm_manager.py

# View vault (decrypt temporarily)
ansible-vault view vault/credentials.yml --ask-vault-pass

# Edit vault
ansible-vault edit vault/credentials.yml --ask-vault-pass

# Test playbook syntax
ansible-playbook playbooks/extend_lvm.yml --syntax-check

# Dry-run playbook
ansible-playbook playbooks/extend_lvm.yml --check --diff

# Run with verbose output
ansible-playbook playbooks/extend_lvm.yml -vvv

# Start EDA controller
./start_eda.sh

# Test webhook
./test_webhook.sh

# View logs
tail -f logs/maintenance.log
```

### Project Manager Quick Menu

| Option | What It Does |
|--------|--------------|
| **1** | View project status, component health |
| **2** | Create/restore backups |
| **5** | Configure credentials (GitHub, ServiceNow, etc.) |
| **7** | Create roles, playbooks, scripts |
| **8** | Test connectivity, validate syntax |
| **9** | Enable dry-run mode (test safely) |
| **D** | Quick toggle dry-run on/off |

### Dry-Run Mode (Safe Testing)

```bash
# From main menu
python aap_lvm_manager.py
# Press D → Enable dry-run mode

# Now all operations are simulated (no changes made)

# View what would be done
# Menu → 9 → 2 (View operation summary)

# Export report
# Menu → 9 → 4 (Export operations)

# Disable to apply changes
# Press D → Disable dry-run mode
```

## Get Help

- **Full Documentation**: `DOC.md`
- **Report Issues**: GitHub Issues
- **Ask Questions**: GitHub Discussions
- **Email**: infra-automation@example.com

## Success Indicators

You're ready to go when you see:

- [DONE] All components created (menu 7 → 14 completes successfully)
- [DONE] Credentials collected and encrypted (`vault/credentials.yml` exists)
- [DONE] AAP configured (playbook completes without errors)
- [DONE] Test playbook runs successfully
- [DONE] Webhook responds (if testing EDA locally)

**Congratulations!** Your LVM Auto-Extension system is operational!

---

**Estimated Total Time**: ~15 minutes 
**Difficulty**: Beginner-friendly 
**Last Updated**: January 6, 2025
