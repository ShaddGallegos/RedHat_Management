# LVM Auto-Extension with Event-Driven Ansible

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Ansible](https://img.shields.io/badge/Ansible-2.9+-blue.svg)](https://www.ansible.com/)
[![Python](https://img.shields.io/badge/Python-3.8+-green.svg)](https://www.python.org/)

Automated disk space management for Linux servers using Event-Driven Ansible (EDA), integrated with Ansible Automation Platform (AAP) 2.5, ServiceNow, and Nutanix.

## Features

- **Real-time Monitoring**: Splunk integration with HEC (HTTP Event Collector)
- [FAST] **Auto-Extension**: Automatic LVM extension when thresholds are exceeded
- **ServiceNow Integration**: Automated incident creation and management
- [CLOUD] **Dynamic Inventories**: 
 - Nutanix Prism Central VM discovery
 - ServiceNow CMDB integration
- **Secure Credentials**: Ansible Vault encrypted credential storage
- **AAP 2.5 Workflows**: Orchestrated automation workflows
- **Project Manager**: Interactive CLI tool for project setup and management
- **Dry-Run Mode**: Test changes safely before applying

## Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Usage](#usage)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Architecture

```
┌─────────────┐ ┌──────────────┐ ┌─────────────┐
│ Splunk │─────▶│ EDA │─────▶│ AAP 2.5 │
│ (HEC) │ │ Controller │ │ Workflow │
└─────────────┘ └──────────────┘ └─────────────┘
 │
 ┌─────────────────────────────┼─────────────┐
 ▼ ▼ ▼
 ┌────────────┐ ┌──────────────┐ ┌──────────┐
 │ Monitor │ │ Extend LVM │ │ServiceNow│
 │ Disk Usage │ │ │ │ Ticket │
 └────────────┘ └──────────────┘ └──────────┘
 │ │
 └─────────────┬───────────────┘
 ▼
 ┌─────────────────┐
 │ Target Servers │
 │ (Nutanix VMs) │
 └─────────────────┘
```

## Prerequisites

### Required Software

- **Python**: 3.8 or higher
- **Ansible**: 2.9 or higher
- **Ansible Automation Platform**: 2.5
- **Operating System**: RHEL 8/9 or compatible

### Required Access

- Red Hat Automation Hub token (for Ansible collections)
- AAP 2.5 Controller with admin access
- ServiceNow instance (optional)
- Nutanix Prism Central (optional)
- Splunk with HEC endpoint (optional)

### Python Packages

```bash
ansible>=2.9
ansible-rulebook>=0.13.0
PyYAML>=5.1
requests>=2.25.0
jinja2>=2.11
```

### Ansible Collections

```yaml
- ansible.posix
- community.general
- ansible.eda
- servicenow.itsm
- ansible.controller
```

## Quick Start

1. **Clone and Setup**:

 ```bash
 cd Add_LVM_to_System_nutanix
 
 # Run interactive manager
 python3 aap_lvm_manager.py
 
 # Or use automated setup
 chmod +x scripts/operations/setup_lvm_automation.sh
./scripts/operations/setup_lvm_automation.sh
 ```

## Project Structure

```
lvm-automation/
├── aap_lvm_manager.py # Project management CLI tool
├── ansible.cfg # Ansible configuration
├── requirements.txt # Python dependencies
├── requirements.yml # Ansible collections
│
├── roles/ # Ansible roles
│ ├── credential_manager/ # Credential collection
│ ├── disk_usage_alerting/ # Disk monitoring
│ ├── lvm_extension_orchestrator/
│ ├── lvm_smart_extend/ # LVM extension logic
│ ├── lvm_system_inspection/ # System inspection
│ └── servicenow_ticket_management/
│
├── playbooks/ # Ansible playbooks
│ ├── complete_setup.yml # Complete setup workflow
│ ├── configure_aap.yml # AAP configuration
│ ├── disk_usage_monitor.yml # Disk monitoring
│ ├── extend_lvm.yml # LVM extension
│ ├── servicenow_create_ticket.yml
│ └── setup_credentials.yml # Credential collection
│
├── inventory/ # Inventory files
│ ├── hosts # Static inventory
│ └── nutanix_dynamic.py # Nutanix dynamic inventory
│
├── vault/ # Encrypted credentials
│ └── credentials.yml # Vault file (encrypted)
│
├── rulebook.yml # EDA webhook rulebook
├── rulebook_splunk.yml # EDA Splunk integration
├── start_eda.sh # EDA startup script
└── test_webhook.sh # Webhook test script
```

## [CONFIG] Configuration

### Environment Variables

The project manager creates `~/.lvm_automation_env`:

```bash
# Red Hat
RH_AUTOMATION_HUB_TOKEN=your_token_here
RH_AUTOMATION_HUB_URL=https://console.redhat.com/api/automation-hub/

# GitHub (optional)
GITHUB_USERNAME=your_username
GITHUB_TOKEN=your_token

# ServiceNow (optional)
SNOW_INSTANCE=dev12345
SNOW_USERNAME=admin
SNOW_PASSWORD=password

# Nutanix (optional)
NUTANIX_HOST=prism-central.example.com
NUTANIX_PORT=9440
NUTANIX_USERNAME=admin
NUTANIX_PASSWORD=password
```

### Vault Credentials

Located in `vault/credentials.yml` (encrypted):

```yaml
servicenow:
 instance: dev12345
 username: admin
 password: secret

nutanix:
 host: prism-central.example.com
 port: 9440
 username: admin
 password: secret

aap:
 controller_url: https://aap.example.com
 username: admin
 password: secret

lvm:
 threshold_percent: 80
 critical_threshold: 90
 extend_percent: 20

splunk:
 url: https://splunk.example.com:8088
 token: your-hec-token
```

## Usage

### Using the Project Manager

```bash
python aap_lvm_manager.py
```

**Main Menu Options:**

1. **Analysis & Reporting**: View project status and component health
2. **Backup & Restore**: Create and restore project backups
3. **Cleanup & Maintenance**: Remove empty dirs, clean backups
4. **Consolidation**: Merge duplicate files (future feature)
5. **Environment Setup**: Configure credentials and environments
6. **Security & Vault Management**: Manage encrypted credentials
7. **Setup & Initialization**: Create and manage project components
8. **Testing & Validation**: Test playbooks, webhooks, and connectivity
9. **Dry-Run / Check Mode**: Test changes without applying them

**Quick Toggle:**
- Press `D` from main menu to toggle dry-run mode

### Dry-Run Mode

Test changes safely before applying:

```bash
# Enable dry-run mode
python aap_lvm_manager.py
# Main menu → press D → Enable dry-run

# Perform operations (no actual changes made)
# Main menu → option 7 → option 14 (Create all)

# View what would be done
# Main menu → option 9 → option 2 (View summary)

# Export report
# Main menu → option 9 → option 4 (Export)

# Disable dry-run to apply changes
# Main menu → press D → Disable dry-run
```

### Manual Playbook Execution

```bash
# Monitor disk usage
ansible-playbook playbooks/disk_usage_monitor.yml \
 -i inventory/hosts \
 -e "threshold_percent=80"

# Extend LVM
ansible-playbook playbooks/extend_lvm.yml \
 -i inventory/hosts \
 -e "mount_point=/ extend_gb=10" \
 --limit target_server

# Create ServiceNow ticket
ansible-playbook playbooks/servicenow_create_ticket.yml \
 --ask-vault-pass \
 -e "hostname=server01 disk_usage_percent=92"
```

### Start EDA Controller

```bash
# Using the provided script
./start_eda.sh

# Or manually
ansible-rulebook \
 --rulebook rulebook_splunk.yml \
 --inventory inventory/hosts \
 --vars vault/credentials.yml \
 --vault-password-file.vault_pass \
 --verbose
```

### Test Webhook

```bash
# Send test alert
./test_webhook.sh

# Or manually
curl -X POST http://localhost:5000/webhook \
 -H 'Content-Type: application/json' \
 -d '{
 "hostname": "test-server",
 "disk_usage_percent": 85
 }'
```

## Testing

### Test Connectivity

From the project manager:
```
Main Menu → 8 (Testing) → 1 (Test Ansible connectivity)
```

### Validate YAML Syntax

```bash
# Check all YAML files
python aap_lvm_manager.py
# Main Menu → 8 → 2 (Validate YAML syntax)
```

### Test Playbook Syntax

```bash
ansible-playbook playbooks/extend_lvm.yml --syntax-check
```

### Dry-Run Playbook

```bash
ansible-playbook playbooks/extend_lvm.yml \
 --check \
 --diff \
 -i inventory/hosts
```

## Troubleshooting

### Common Issues

**1. Ansible Vault Errors**

```bash
# If you forgot the vault password
ansible-vault view vault/credentials.yml
# Enter vault password when prompted

# Decrypt vault temporarily
ansible-vault decrypt vault/credentials.yml
#... make changes...
ansible-vault encrypt vault/credentials.yml
```

**2. AAP Connection Failed**

```bash
# Test AAP connectivity
curl -k -u admin:password https://aap.example.com/api/v2/ping/

# Check credentials in vault
ansible-vault view vault/credentials.yml --vault-password-file.vault_pass
```

**3. Nutanix Inventory Empty**

```bash
# Test Nutanix connection
python inventory/nutanix_dynamic.py

# Set environment variables
export NUTANIX_HOST=prism-central.example.com
export NUTANIX_USER=admin
export NUTANIX_PASS=password
```

**4. Splunk HEC Not Working**

```bash
# Test HEC endpoint
curl -k https://splunk.example.com:8088/services/collector \
 -H "Authorization: Splunk your-hec-token" \
 -d '{"event": "test"}'
```

### Debug Mode

Enable debug logging:

```bash
# In playbooks
ansible-playbook playbooks/extend_lvm.yml -vvv

# In EDA rulebook
ansible-rulebook --rulebook rulebook.yml --verbose
```

### View Logs

```bash
# Project manager logs
tail -f logs/maintenance.log

# AAP job logs
# View in AAP web UI: Jobs → Select job → Output
```

## Security Best Practices

1. **Never commit credentials**: `.vault_pass` is in `.gitignore`
2. **Use Ansible Vault**: All sensitive data encrypted
3. **Rotate passwords**: Use project manager Security menu
4. **Limit AAP access**: Use RBAC in AAP
5. **Secure environment file**: `~/.lvm_automation_env` has 600 permissions
6. **Use SSH keys**: Configure in inventory with `ansible_ssh_private_key_file`

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Workflow

```bash
# Enable dry-run mode for testing
python aap_lvm_manager.py
# Press D to enable dry-run

# Make changes
# Test with dry-run mode

# Review changes
git diff

# Commit
git commit -am "Description of changes"
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Red Hat Ansible Automation Platform team
- Nutanix automation community
- ServiceNow integration contributors

## Support

- **Issues**: [GitHub Issues](https://github.com/your-org/lvm-automation/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/lvm-automation/discussions)
- **Documentation**: [docs/](docs/)

## Roadmap

- [ ] Add support for AWS EC2 dynamic inventory
- [ ] Implement automated testing suite
- [ ] Add Prometheus/Grafana monitoring
- [ ] Create web dashboard
- [ ] Support for other filesystems (ext4, btrfs)
- [ ] Multi-cloud support (Azure, GCP)

---

**Made with by the Infrastructure Automation Team**
