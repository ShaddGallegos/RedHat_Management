# Converted Script Playbooks
This directory contains Ansible playbooks that have been converted from shell scripts.
## Original Scripts Location
Original shell scripts have been backed up to: `scripts/backup/`
## Available Playbooks
### 00_master_setup.yml
Master playbook that runs all setup tasks in order.
**Usage:**
```bash
ansible-playbook playbooks/converted_scripts/00_master_setup.yml
```
### install_redhat_collections.yml
Installs Red Hat certified and community Ansible collections.
**Usage:**
```bash
ansible-playbook playbooks/converted_scripts/install_redhat_collections.yml
```
### setup_lvm_automation.yml
Sets up the LVM automation environment including directories, requirements, and configuration files.
**Usage:**
```bash
ansible-playbook playbooks/converted_scripts/setup_lvm_automation.yml
```
### start_eda.yml
Starts the Event Driven Ansible controller as a background process.
**Usage:**
```bash
ansible-playbook playbooks/converted_scripts/start_eda.yml
```
### stop_eda.yml
Stops the Event Driven Ansible controller.
**Usage:**
```bash
ansible-playbook playbooks/converted_scripts/stop_eda.yml
```
### setup_monitoring_cron.yml
Sets up cron jobs for disk monitoring on target servers.
**Usage:**
```bash
ansible-playbook playbooks/converted_scripts/setup_monitoring_cron.yml -i inventory/hosts
```
## Benefits of Playbook Conversion
1. **Idempotency**: Playbooks can be run multiple times safely
2. **Better Error Handling**: Built-in error handling and rollback
3. **Modularity**: Tasks can be reused across playbooks
4. **Testing**: Can use --check mode for dry runs
5. **Integration**: Works seamlessly with AAP/AWX
6. **Logging**: Better logging and audit trail
7. **Variables**: Easy variable management and templating
## Running with Tags
You can run specific parts of the master playbook:
```bash
# Only install collections
ansible-playbook playbooks/converted_scripts/00_master_setup.yml --tags collections
# Only setup environment
ansible-playbook playbooks/converted_scripts/00_master_setup.yml --tags environment
```
## Dry Run Mode
Test playbooks without making changes:
```bash
ansible-playbook playbooks/converted_scripts/00_master_setup.yml --check
```
## Reverting to Shell Scripts
If you need to use the original shell scripts, they are backed up in:
```
scripts/backup/
```
## Conversion Report
See the detailed conversion report at:
```
logs/script_conversion_report_TIMESTAMP.txt
```
