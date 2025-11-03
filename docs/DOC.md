# LVM Auto-Extension - Detailed Documentation

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Component Details](#component-details)
3. [Workflow Details](#workflow-details)
4. [Configuration Reference](#configuration-reference)
5. [API Reference](#api-reference)
6. [Advanced Usage](#advanced-usage)
7. [Extending the Project](#extending-the-project)

---

## 1. Architecture Overview

### High-Level Design

```
┌─────────────────────────────────────────────────────────────┐
│ Monitoring Layer │
│ ┌────────────┐ ┌────────────┐ ┌────────────┐ │
│ │ Splunk │ │ Webhook │ │ Manual │ │
│ │ HEC │ │ Triggers │ │ Triggers │ │
│ └──────┬─────┘ └──────┬─────┘ └──────┬─────┘ │
└─────────┼────────────────┼────────────────┼─────────────────┘
 │ │ │
 └────────────────┼────────────────┘
 ▼
┌─────────────────────────────────────────────────────────────┐
│ Event-Driven Ansible (EDA) │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ Rule Engine: │ │
│ │ • Threshold evaluation (>80% disk usage) │ │
│ │ • Severity classification │ │
│ │ • Event enrichment │ │
│ └──────────────────────────────────────────────────────┘ │
└─────────────────────────┬───────────────────────────────────┘
 ▼
┌─────────────────────────────────────────────────────────────┐
│ Ansible Automation Platform 2.5 │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ Workflow Template: │ │
│ │ 1. Inventory sync (ServiceNow/Nutanix) │ │
│ │ 2. Monitor disk usage │ │
│ │ 3. Extend LVM (if needed) │ │
│ │ 4. Create ServiceNow ticket (if failed) │ │
│ │ 5. Send notifications │ │
│ └──────────────────────────────────────────────────────┘ │
└─────────────────────────┬───────────────────────────────────┘
 ▼
┌─────────────────────────────────────────────────────────────┐
│ Execution Layer │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│ │ Target │ │ ServiceNow │ │ Logging │ │
│ │ Servers │ │ ITSM │ │ & Audit │ │
│ │ (Linux) │ │ │ │ │ │
│ └─────────────┘ └─────────────┘ └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Monitoring** | Splunk HEC | Event ingestion and alerting |
| **Event Processing** | Ansible EDA | Rule-based event processing |
| **Orchestration** | AAP 2.5 | Workflow automation and execution |
| **Inventory** | Nutanix, ServiceNow | Dynamic server discovery |
| **Execution** | Ansible | Configuration management |
| **Security** | Ansible Vault | Credential encryption |
| **ITSM** | ServiceNow | Incident management |

---

## 2. Component Details

### 2.1 Roles

#### `lvm_smart_extend`

**Purpose**: Intelligently extend LVM logical volumes

**Variables**:
```yaml
lvm_threshold_percent: 80 # Trigger threshold
lvm_critical_threshold: 90 # Critical threshold
lvm_extend_percent: 20 # Extension percentage
lvm_min_extend_gb: 10 # Minimum extension size
lvm_max_extend_gb: 100 # Maximum extension size
lvm_vg_name: "rhel" # Volume group name
lvm_lv_name: "root" # Logical volume name
lvm_mount_point: "/" # Mount point to extend
```

**Tasks Flow**:
1. Gather disk usage facts
2. Check volume group free space
3. Calculate extension size
4. Extend logical volume
5. Resize filesystem (xfs_growfs or resize2fs)
6. Verify extension
7. Update monitoring

**Example Usage**:
```yaml
- hosts: servers
 roles:
 - role: lvm_smart_extend
 vars:
 lvm_mount_point: "/var"
 lvm_extend_percent: 25
```

#### `lvm_system_inspection`

**Purpose**: Gather LVM and disk usage information

**Collected Facts**:
- Volume group details
- Logical volume details
- Physical volume details
- Filesystem usage
- Disk I/O statistics
- Historical usage trends

**Usage**:
```yaml
- hosts: servers
 roles:
 - lvm_system_inspection

- debug:
 var: lvm_facts
```

#### `servicenow_ticket_management`

**Purpose**: Create and manage ServiceNow incidents

**Variables**:
```yaml
snow_priority: 3 # Incident priority (1-5)
snow_category: "Disk Space" # Incident category
snow_assignment_group: "Linux" # Assignment group
snow_auto_close: true # Auto-close on success
snow_work_notes: "" # Additional notes
```

**Workflow**:
1. Check if ticket exists for server
2. Create new incident if needed
3. Update existing ticket with progress
4. Close ticket if resolved
5. Escalate if critical

#### `credential_manager`

**Purpose**: Interactive credential collection and storage

**Features**:
- Interactive prompts for all credentials
- Validation of credential format
- Secure storage in Ansible Vault
- Support for multiple credential types

**Collected Credentials**:
- ServiceNow (instance, username, password)
- Nutanix (host, port, username, password)
- AAP (controller URL, username, password)
- Splunk (HEC URL, token)
- LVM thresholds

### 2.2 Playbooks

#### `disk_usage_monitor.yml`

**Purpose**: Monitor disk usage across all servers

```yaml
---
- name: Monitor Disk Usage
 hosts: all
 gather_facts: true
 
 vars:
 threshold_percent: 80
 critical_threshold: 90
 
 tasks:
 - name: Collect disk usage
 command: df -h
 register: disk_usage
 changed_when: false
 
 - name: Parse usage
 set_fact:
 usage_data: "{{ disk_usage.stdout | parse_df }}"
 
 - name: Alert on high usage
 debug:
 msg: "High disk usage: {{ item.mount }} at {{ item.percent }}%"
 when: item.percent | int > threshold_percent
 loop: "{{ usage_data }}"
 
 - name: Trigger extension
 include_role:
 name: lvm_smart_extend
 when: item.percent | int > critical_threshold
 loop: "{{ usage_data }}"
```

#### `configure_aap.yml`

**Purpose**: Complete AAP 2.5 configuration

**What it configures**:

1. **Custom Credential Types**:
 - Nutanix (host, port, username, password)
 - Splunk HEC (URL, token)

2. **Credentials**:
 - ServiceNow production
 - Nutanix production
 - Splunk HEC production

3. **Projects**:
 - Git-based project from repository
 - Auto-update on launch

4. **Inventories**:
 - ServiceNow CMDB dynamic inventory
 - Nutanix VMs dynamic inventory

5. **Job Templates**:
 - Monitor Disk Usage
 - Extend LVM
 - Create ServiceNow Ticket

6. **Workflow Template**:
 - Complete automation workflow
 - Conditional branching
 - Error handling

7. **EDA Controller**:
 - Project configuration
 - Decision environment
 - Rulebook activations

### 2.3 Event-Driven Ansible

#### Webhook Rulebook (`rulebook.yml`)

```yaml
---
- name: LVM Auto-Extension Rulebook
 hosts: all
 
 sources:
 - ansible.eda.webhook:
 host: 0.0.0.0
 port: 5000
 
 rules:
 - name: High disk usage warning
 condition: >
 event.payload.disk_usage_percent > 80 and
 event.payload.disk_usage_percent < 90
 action:
 run_playbook:
 name: playbooks/disk_usage_monitor.yml
 extra_vars:
 target_host: "{{ event.payload.hostname }}"
 
 - name: Critical disk usage - auto-extend
 condition: event.payload.disk_usage_percent >= 90
 action:
 run_workflow:
 name: "LVM Auto-Extension Workflow"
 extra_vars:
 target_host: "{{ event.payload.hostname }}"
 mount_point: "{{ event.payload.mount_point | default('/') }}"
```

#### Splunk Rulebook (`rulebook_splunk.yml`)

```yaml
---
- name: Splunk Integration
 hosts: all
 
 sources:
 - ansible.eda.splunk:
 url: "{{ splunk_url }}"
 token: "{{ splunk_token }}"
 search: >
 search index=linux sourcetype=df
 | where used_percent > 80
 | table host, filesystem, used_percent
 
 rules:
 - name: Process Splunk alerts
 condition: event.result.used_percent > 80
 action:
 run_job_template:
 name: "Monitor Disk Usage"
 organization: "Default"
 extra_vars:
 target_host: "{{ event.result.host }}"
 mount_point: "{{ event.result.filesystem }}"
```

### 2.4 Dynamic Inventories

#### Nutanix Inventory (`inventory/nutanix_dynamic.py`)

**Features**:
- Discovers all VMs from Prism Central
- Extracts IP addresses from NICs
- Creates groups based on VM properties
- Supports filtering by tags

**Environment Variables**:
```bash
NUTANIX_HOST=prism-central.example.com
NUTANIX_PORT=9440
NUTANIX_USER=admin
NUTANIX_PASS=password
```

**Output Format**:
```json
{
 "_meta": {
 "hostvars": {
 "vm-server01": {
 "ansible_host": "192.168.1.100",
 "nutanix_vm_uuid": "abc-123-def",
 "ansible_user": "ansible",
 "ansible_become": true
 }
 }
 },
 "all": {
 "children": ["nutanix_vms"]
 },
 "nutanix_vms": {
 "hosts": ["vm-server01", "vm-server02"]
 }
}
```

#### ServiceNow Inventory

Configured in AAP as inventory source:

```yaml
source: servicenow
credential: ServiceNow Production
source_vars:
 table: cmdb_ci_linux_server
 fields:
 - name
 - ip_address
 - sys_class_name
 - u_environment
 filter: operational_status=1
 compose:
 ansible_host: ip_address
 environment: u_environment
```

---

## 3. Workflow Details

### AAP Workflow Template: "LVM Auto-Extension Workflow"

```
┌─────────────────────────────────────────────────┐
│ START │
└────────────────────┬────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────┐
│ Node 1: Sync Inventories │
│ - ServiceNow CMDB │
│ - Nutanix VMs │
└────────────────────┬────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────┐
│ Node 2: Monitor Disk Usage │
│ Job Template: "Monitor Disk Usage" │
│ Survey: target_host, mount_point │
└────────┬──────────────────────┬─────────────────┘
 │ SUCCESS │ FAILURE
 ▼ ▼
┌──────────────────┐ ┌────────────────────────┐
│ Node 3: │ │ Node 5: │
│ Check Threshold │ │ Create Ticket │
│ (>90%) │ │ Priority: High │
└────┬─────────────┘ └────────────────────────┘
 │ YES
 ▼
┌──────────────────────────────────────────────────┐
│ Node 4: Extend LVM │
│ Job Template: "Extend LVM" │
│ Survey: mount_point, extend_gb │
└────────┬──────────────────────┬──────────────────┘
 │ SUCCESS │ FAILURE
 ▼ ▼
┌──────────────────┐ ┌────────────────────────┐
│ Node 6: │ │ Node 7: │
│ Verify │ │ Create Critical │
│ Extension │ │ Ticket │
└────────┬─────────┘ └────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────┐
│ Node 8: Send Notifications │
│ - Email team │
│ - Update monitoring │
└────────────────────┬────────────────────────────┘
 │
 ▼
┌─────────────────────────────────────────────────┐
│ END │
└─────────────────────────────────────────────────┘
```

### Execution Flow with Conditions

```yaml
# Workflow node configuration (pseudo-code)
workflow_nodes:
 - node: sync_inventories
 type: inventory_sync
 success: monitor_usage
 
 - node: monitor_usage
 type: job_template
 template: "Monitor Disk Usage"
 success: check_threshold
 failure: create_ticket_monitor_failed
 
 - node: check_threshold
 type: approval
 timeout: 300
 success: extend_lvm
 denied: end
 
 - node: extend_lvm
 type: job_template
 template: "Extend LVM"
 success: verify_extension
 failure: create_ticket_extend_failed
 
 - node: verify_extension
 type: job_template
 template: "Verify Disk Space"
 success: notify_success
 failure: create_ticket_verify_failed
 
 - node: notify_success
 type: job_template
 template: "Send Notifications"
 success: end
```

---

## 4. Configuration Reference

### 4.1 Environment Configuration

Location: `~/.lvm_automation_env`

```ini
# Red Hat Automation Hub
RH_AUTOMATION_HUB_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJS...
RH_AUTOMATION_HUB_URL=https://console.redhat.com/api/automation-hub/

# GitHub
GITHUB_USERNAME=your-username
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
GITHUB_REPO_URL=https://github.com/your-org/lvm-automation.git

# ServiceNow
SNOW_INSTANCE=dev12345
SNOW_USERNAME=admin
SNOW_PASSWORD=secure_password

# Nutanix
NUTANIX_HOST=prism-central.example.com
NUTANIX_PORT=9440
NUTANIX_USERNAME=admin
NUTANIX_PASSWORD=secure_password

# System
ANSIBLE_PRIVATE_KEY_FILE=~/.ssh/id_rsa
ANSIBLE_REMOTE_USER=ansible
```

### 4.2 Vault Credentials

Location: `vault/credentials.yml` (encrypted with Ansible Vault)

```yaml
servicenow:
 instance: dev12345
 username: admin
 password:!vault |
 $ANSIBLE_VAULT;1.1;AES256
...encrypted...

nutanix:
 host: prism-central.example.com
 port: 9440
 username: admin
 password:!vault |
 $ANSIBLE_VAULT;1.1;AES256
...encrypted...

aap:
 controller_url: https://aap.example.com
 username: admin
 password:!vault |
 $ANSIBLE_VAULT;1.1;AES256
...encrypted...

lvm:
 threshold_percent: 80
 critical_threshold: 90
 extend_percent: 20
 min_extend_gb: 10
 max_extend_gb: 100

splunk:
 url: https://splunk.example.com:8088
 token:!vault |
 $ANSIBLE_VAULT;1.1;AES256
...encrypted...
```

### 4.3 Ansible Configuration

Location: `ansible.cfg`

```ini
[defaults]
collections_paths =./collections
roles_path =./roles
inventory =./inventory/hosts
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
bin_ansible_callbacks = True
interpreter_python = auto_silent
callback_whitelist = timer, profile_tasks
display_skipped_hosts = False
command_warnings = False
deprecation_warnings = False

[inventory]
unparsed_is_failed = False
enable_plugins = host_list, script, auto, yaml, ini, toml

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
pipelining = True
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
control_path = /tmp/ansible-ssh-%%h-%%p-%%r

[galaxy]
server_list = published, validated, community_galaxy

[galaxy_server.published]
url = https://console.redhat.com/api/automation-hub/content/published/
auth_url = https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
token = ${RH_AUTOMATION_HUB_TOKEN}

[galaxy_server.validated]
url = https://console.redhat.com/api/automation-hub/content/validated/
auth_url = https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
token = ${RH_AUTOMATION_HUB_TOKEN}

[galaxy_server.community_galaxy]
url = https://galaxy.ansible.com/
```

---

## 5. API Reference

### 5.1 Webhook API

**Endpoint**: `POST http://localhost:5000/webhook`

**Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
 "hostname": "server01",
 "disk_usage_percent": 85,
 "mount_point": "/",
 "filesystem": "/dev/mapper/rhel-root",
 "available_gb": 5.2,
 "total_gb": 50,
 "timestamp": "2025-01-06T10:30:00Z"
}
```

**Response**:
```json
{
 "status": "accepted",
 "event_id": "abc-123-def",
 "message": "Event queued for processing"
}
```

### 5.2 AAP Controller API

**Base URL**: `https://aap.example.com/api/v2/`

**Authentication**: Basic Auth or OAuth2 Token

#### Launch Job Template

```bash
curl -X POST \
 https://aap.example.com/api/v2/job_templates/123/launch/ \
 -u admin:password \
 -H 'Content-Type: application/json' \
 -d '{
 "extra_vars": {
 "target_host": "server01",
 "mount_point": "/"
 },
 "limit": "server01"
 }'
```

#### Launch Workflow Template

```bash
curl -X POST \
 https://aap.example.com/api/v2/workflow_job_templates/456/launch/ \
 -u admin:password \
 -H 'Content-Type: application/json' \
 -d '{
 "extra_vars": {
 "target_host": "server01"
 }
 }'
```

#### Get Job Status

```bash
curl -X GET \
 https://aap.example.com/api/v2/jobs/789/ \
 -u admin:password
```

---

## 6. Advanced Usage

### 6.1 Custom Thresholds per Host

Define in `group_vars/` or `host_vars/`:

```yaml
# host_vars/critical-server.yml
lvm_threshold_percent: 70
lvm_critical_threshold: 85
lvm_extend_percent: 30
```

### 6.2 Multi-Mount Point Extension

```yaml
# Extend multiple filesystems
- hosts: servers
 vars:
 mount_points:
 - path: "/"
 extend_gb: 10
 - path: "/var"
 extend_gb: 20
 - path: "/home"
 extend_gb: 15
 
 tasks:
 - include_role:
 name: lvm_smart_extend
 vars:
 lvm_mount_point: "{{ item.path }}"
 lvm_extend_gb: "{{ item.extend_gb }}"
 loop: "{{ mount_points }}"
```

### 6.3 Conditional Extension

```yaml
- name: Extend only if VG has space
 hosts: servers
 tasks:
 - name: Check VG free space
 command: vgs --noheadings -o vg_free --units g rhel
 register: vg_free
 changed_when: false
 
 - name: Extract free space
 set_fact:
 vg_free_gb: "{{ vg_free.stdout | regex_replace('g', '') | float }}"
 
 - name: Extend LVM
 include_role:
 name: lvm_smart_extend
 when: vg_free_gb | float > 20
```

### 6.4 Integration with External Monitoring

```yaml
# Send metrics to Prometheus
- name: Export metrics
 hosts: servers
 tasks:
 - name: Create metrics file
 copy:
 content: |
 # HELP disk_usage_percent Disk usage percentage
 # TYPE disk_usage_percent gauge
 disk_usage_percent{mount="{{ ansible_mounts[0].mount }}"} {{ ansible_mounts[0].size_used_percent }}
 dest: /var/lib/node_exporter/textfile_collector/disk.prom
```

---

## 7. Extending the Project

### 7.1 Adding New Roles

```bash
# Use project manager
python aap_lvm_manager.py
# Menu → 7 → 3 (Create missing roles)

# Or manually
ansible-galaxy init roles/my_new_role
```

### 7.2 Custom Event Sources

```yaml
# rulebook_custom.yml
---
- name: Custom Event Source
 hosts: all
 
 sources:
 - my_namespace.my_collection.custom_source:
 option1: value1
 
 rules:
 - name: Custom rule
 condition: event.custom_field == "value"
 action:
 run_playbook:
 name: playbooks/custom_action.yml
```

### 7.3 Adding New Playbooks

```yaml
# playbooks/my_custom_playbook.yml
---
- name: My Custom Automation
 hosts: "{{ target_host | default('all') }}"
 gather_facts: true
 
 vars:
 custom_var: "value"
 
 tasks:
 - name: Custom task
 debug:
 msg: "Performing custom action"
```

### 7.4 Creating Custom Credential Types

In AAP Controller:

```yaml
name: "My Custom Credential"
kind: cloud
inputs:
 fields:
 - id: api_url
 type: string
 label: API URL
 - id: api_key
 type: string
 label: API Key
 secret: true
injectors:
 env:
 MY_API_URL: "{{ api_url }}"
 MY_API_KEY: "{{ api_key }}"
```

---

## Appendix A: Troubleshooting Guide

### Issue: Playbook fails with "Vault password not provided"

**Solution**:
```bash
# Option 1: Use password file
ansible-playbook playbooks/extend_lvm.yml --vault-password-file.vault_pass

# Option 2: Prompt for password
ansible-playbook playbooks/extend_lvm.yml --ask-vault-pass

# Option 3: Set environment variable
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
ansible-playbook playbooks/extend_lvm.yml
```

### Issue: Dynamic inventory returns no hosts

**Solution**:
```bash
# Test inventory directly
python inventory/nutanix_dynamic.py

# Check environment variables
env | grep NUTANIX

# Verify credentials
curl -k -u admin:password \
 https://prism-central:9440/api/nutanix/v3/vms/list \
 -X POST -d '{"kind":"vm"}'
```

### Issue: EDA rulebook not triggering

**Solution**:
```bash
# Enable verbose logging
ansible-rulebook --rulebook rulebook.yml -vvv

# Test webhook manually
curl -X POST http://localhost:5000/webhook \
 -H 'Content-Type: application/json' \
 -d '{"hostname":"test","disk_usage_percent":85}'

# Check EDA controller logs
journalctl -u ansible-eda -f
```

---

## Appendix B: Performance Tuning

### Ansible Forks

```ini
# ansible.cfg
[defaults]
forks = 50 # Increase for parallel execution
```

### Pipelining

```ini
# ansible.cfg
[ssh_connection]
pipelining = True # Reduce SSH overhead
```

### Fact Caching

```ini
# ansible.cfg
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 3600
```

---

**Document Version**: 1.0 
**Last Updated**: January 6, 2025 
**Maintainer**: Infrastructure Automation Team