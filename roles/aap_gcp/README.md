# AAP GCP Integration Role

This Ansible role automates the creation of all components needed for integrating Google Cloud Platform (GCP) with Ansible Automation Platform 2.6 and Red Hat Satellite 6.18.

## Description

This role generates a complete project structure with all configuration files, playbooks, inventories, and AAP resources needed for seamless GCP-to-Satellite integration as described in the AAP 2.6 GCP Integration Guide.

## Requirements

- Ansible 2.15+
- Collections:
  - `google.cloud` (1.3.0+)
  - `redhat.satellite` (4.0.0+)
  - `awx.awx` (24.0.0+)
  - `infra.controller_configuration` (2.7.0+)
  - `community.general` (9.0.0+)

## Role Variables

### Project Configuration
- `aap_gcp_project_name`: Name of the project (default: `gcp-satellite-integration`)
- `aap_gcp_base_dir`: Base directory for project files (default: `~/aap-gcp-project`)
- `aap_gcp_create_structure`: Whether to create directory structure (default: `true`)

### GCP Configuration
- `aap_gcp_project_id`: GCP project ID (required)
- `aap_gcp_service_account_file`: Path to GCP service account JSON key (default: `~/.gcp/service-account-key.json`)
- `aap_gcp_zones`: List of GCP zones (default: `['us-central1-a', 'us-central1-b', 'us-east1-c']`)
- `aap_gcp_region`: GCP region (default: `us-central1`)

### Satellite Configuration
- `aap_satellite_url`: Satellite server URL (required)
- `aap_satellite_organization`: Satellite organization (default: `Default_Organization`)
- `aap_satellite_location`: Satellite location (default: `Default_Location`)
- `aap_satellite_hostgroup`: Host group name (default: `GCP_RHEL_Production`)
- `aap_satellite_activation_key`: Activation key (default: `gcp-rhel-prod-key`)
- `aap_satellite_username`: Satellite admin username (default: `admin`)
- `aap_satellite_verify_ssl`: Verify SSL certificates (default: `false`)

### AAP Configuration
- `aap_controller_hostname`: AAP controller hostname (optional)
- `aap_controller_username`: AAP admin username (default: `admin`)
- `aap_configure_aap`: Whether to configure AAP resources (default: `false`)
- `aap_execution_environment_image`: EE image tag (default: `quay.io/your-org/ee-gcp-satellite:1.0.0`)

### Workflow Configuration
- `aap_workflow_approval_timeout`: Approval node timeout in seconds (default: `3600`)
- `aap_workflow_job_timeout`: Job template timeout in seconds (default: `1800`)
- `aap_workflow_job_forks`: Number of parallel forks (default: `10`)
- `aap_workflow_serial_execution`: Serial execution count (default: `5`)

### Notification Configuration
- `aap_notification_slack_webhook`: Slack webhook URL (optional)
- `aap_notification_slack_channel`: Slack channel (default: `#infrastructure-alerts`)
- `aap_notification_email_host`: SMTP host (optional)
- `aap_notification_email_port`: SMTP port (default: `587`)
- `aap_notification_sender_email`: Sender email address (optional)

### Security Configuration
- `aap_vault_password`: Ansible Vault password (optional, will be generated if not provided)
- `aap_satellite_password`: Satellite admin password (required for AAP configuration)
- `aap_gcp_inventory_cache_timeout`: Inventory cache timeout in seconds (default: `3600`)

## Dependencies

None

## Example Playbook

### Minimal Example (Generate Files Only)

```yaml
---
- name: Generate GCP-AAP Integration Project
  hosts: localhost
  gather_facts: false
  
  roles:
    - role: aap_gcp
      vars:
        aap_gcp_project_id: "my-gcp-project"
        aap_satellite_url: "https://satellite.example.com"
        aap_satellite_password: "SecretPassword"
```

### Full Example (Generate Files + Configure AAP)

```yaml
---
- name: Generate and Configure GCP-AAP Integration
  hosts: localhost
  gather_facts: false
  
  roles:
    - role: aap_gcp
      vars:
        # Project settings
        aap_gcp_project_name: "production-gcp-integration"
        aap_gcp_base_dir: "/opt/ansible/projects/gcp-satellite"
        
        # GCP settings
        aap_gcp_project_id: "prod-gcp-project-12345"
        aap_gcp_service_account_file: "/secure/gcp-sa-key.json"
        aap_gcp_zones:
          - us-east1-b
          - us-east1-c
          - us-east1-d
        aap_gcp_region: "us-east1"
        
        # Satellite settings
        aap_satellite_url: "https://satellite.production.example.com"
        aap_satellite_organization: "Production"
        aap_satellite_location: "US-East"
        aap_satellite_hostgroup: "GCP_RHEL9_Production"
        aap_satellite_activation_key: "gcp-rhel9-prod-key"
        aap_satellite_username: "admin"
        aap_satellite_password: "{{ vault_satellite_password }}"
        aap_satellite_verify_ssl: true
        
        # AAP settings
        aap_controller_hostname: "aap-controller.example.com"
        aap_controller_username: "admin"
        aap_configure_aap: true
        aap_execution_environment_image: "quay.io/myorg/ee-gcp-satellite:2.0.0"
        
        # Workflow settings
        aap_workflow_approval_timeout: 7200
        aap_workflow_job_forks: 20
        aap_workflow_serial_execution: 10
        
        # Notification settings
        aap_notification_slack_webhook: "{{ vault_slack_webhook }}"
        aap_notification_slack_channel: "#production-alerts"
        aap_notification_email_host: "smtp.office365.com"
        aap_notification_sender_email: "aap-prod@example.com"
```

### Using with Vault

```yaml
---
- name: Secure GCP-AAP Integration Setup
  hosts: localhost
  gather_facts: false
  
  vars_files:
    - vault_secrets.yml
  
  roles:
    - role: aap_gcp
      vars:
        aap_gcp_project_id: "{{ vault_gcp_project_id }}"
        aap_satellite_url: "{{ vault_satellite_url }}"
        aap_satellite_password: "{{ vault_satellite_password }}"
        aap_controller_hostname: "{{ vault_aap_hostname }}"
        aap_notification_slack_webhook: "{{ vault_slack_webhook }}"
```

## What This Role Creates

### Directory Structure
```
<base_dir>/
├── ansible.cfg
├── inventories/
│   └── gcp_dynamic.yml
├── playbooks/
│   ├── gcp_satellite_registration.yml
│   └── export_aap_config.yml
├── group_vars/
│   └── all/
│       ├── vars.yml
│       └── vault.yml (encrypted)
├── roles/
├── execution_environments/
│   └── ee_gcp_satellite.yml
├── collections/
│   └── requirements.yml
├── logs/
└── .gitignore
```

### Configuration Files

1. **ansible.cfg** - Ansible configuration with GCP plugin, vault, and SSH settings
2. **inventories/gcp_dynamic.yml** - GCP dynamic inventory with caching and grouping
3. **playbooks/gcp_satellite_registration.yml** - Main registration playbook with:
   - Pre-flight SSH checks
   - RHEL validation
   - RHUI cleanup
   - Satellite registration
   - Host group assignment
4. **group_vars/all/vars.yml** - Non-sensitive variables
5. **group_vars/all/vault.yml** - Encrypted credentials
6. **execution_environments/ee_gcp_satellite.yml** - Execution environment definition
7. **collections/requirements.yml** - Required Ansible collections
8. **playbooks/export_aap_config.yml** - AAP configuration export playbook

### AAP Resources (if aap_configure_aap: true)

1. **Credentials**:
   - GCP Service Account credential
   - Satellite API credential
   - Machine (SSH) credential
   - Vault credential

2. **Project**: Git-based project configuration

3. **Inventory**: Dynamic GCP inventory with auto-sync

4. **Job Template**: Registration job with all credentials attached

5. **Workflow Template**: 5-node workflow:
   - Inventory Sync
   - Approval Gate
   - Registration Job
   - Success Notification
   - Failure Notification

6. **Notification Templates**: Slack/Email notifications

## Usage

### Step 1: Install the Role

```bash
# If using in a collection
ansible-galaxy collection install -r requirements.yml

# If using standalone
git clone <repo> roles/aap_gcp
```

### Step 2: Create Your Playbook

```bash
cat > setup_gcp_integration.yml <<EOF
---
- name: Setup GCP-AAP Integration
  hosts: localhost
  gather_facts: false
  
  roles:
    - role: aap_gcp
      vars:
        aap_gcp_project_id: "my-project-id"
        aap_satellite_url: "https://satellite.example.com"
        aap_satellite_password: "MyPassword"
EOF
```

### Step 3: Run the Role

```bash
# Generate files only
ansible-playbook setup_gcp_integration.yml

# Generate files and configure AAP
ansible-playbook setup_gcp_integration.yml -e "aap_configure_aap=true"

# Using vault
ansible-playbook setup_gcp_integration.yml --ask-vault-pass
```

### Step 4: Navigate to Generated Project

```bash
cd ~/aap-gcp-project  # Or your custom base_dir
ls -la
```

### Step 5: Test the Setup

```bash
# Verify GCP inventory
ansible-inventory -i inventories/gcp_dynamic.yml --list

# Test the registration playbook
ansible-playbook playbooks/gcp_satellite_registration.yml --check
```

## Post-Installation Steps

After running this role, you need to:

1. **Update GCP Service Account Key**:
   ```bash
   cp /path/to/your/gcp-key.json ~/.gcp/service-account-key.json
   chmod 600 ~/.gcp/service-account-key.json
   ```

2. **Set Vault Password**:
   ```bash
   echo "your_vault_password" > ~/.ansible/conf/.vault_pass.txt
   chmod 600 ~/.ansible/conf/.vault_pass.txt
   ```

3. **Review Generated Variables**:
   ```bash
   vim group_vars/all/vars.yml
   ```

4. **Build Execution Environment** (if needed):
   ```bash
   ansible-builder build \
     --tag quay.io/your-org/ee-gcp-satellite:1.0.0 \
     --file execution_environments/ee_gcp_satellite.yml \
     --container-runtime podman
   ```

5. **Push EE to Registry**:
   ```bash
   podman push quay.io/your-org/ee-gcp-satellite:1.0.0
   ```

6. **Configure AAP** (if not done automatically):
   - Manually create credentials in AAP UI
   - Create project pointing to your Git repo
   - Create inventory with GCP source
   - Create job templates and workflows

## Tags

This role supports the following tags for selective execution:

- `structure` - Create directory structure only
- `configs` - Generate configuration files only
- `playbooks` - Generate playbooks only
- `templates` - Generate template files only
- `aap` - Configure AAP resources only
- `credentials` - Configure AAP credentials only
- `notifications` - Configure AAP notifications only
- `workflow` - Configure AAP workflow only

Example:
```bash
ansible-playbook setup.yml --tags="structure,configs"
```

## License

Apache-2.0

## Author Information

Red Hat Management Team
