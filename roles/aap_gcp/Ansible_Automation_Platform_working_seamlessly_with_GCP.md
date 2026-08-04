---
title: "Ansible Automation Platform 2.6 with GCP"
subtitle: "Production Integration Guide"
author: "Red Hat Management Team"
date: "February 2026"
version: "1.0"
document-class: article
geometry: margin=1in
fontsize: 11pt
toc: true
toc-depth: 3
numberSections: true
colorlinks: true
linkcolor: blue
urlcolor: blue
header-includes: |
  \usepackage{fancyhdr}
  \pagestyle{fancy}
  \fancyhead[L]{AAP 2.6 + GCP Integration}
  \fancyhead[R]{\thepage}
  \fancyfoot[C]{Confidential - Red Hat}
---

# Ansible Automation Platform 2.6 with GCP - Production Integration Guide

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Architecture](#architecture)
4. [Local Development Setup](#local-development-setup)
5. [AAP 2.6 Configuration](#aap-configuration)
6. [Workflow Implementation](#workflow-implementation)
7. [Execution and Operations](#execution-and-operations)
8. [Troubleshooting and Validation](#troubleshooting-and-validation)

\newpage

## Overview

This guide provides a comprehensive, production-ready approach to integrating Google Cloud Platform (GCP) with Ansible Automation Platform 2.6 and Red Hat Satellite 6.18. The workflow enables automatic discovery, validation, approval, and registration of GCP RHEL instances to Satellite for centralized lifecycle management.

### Key Features
- **Dynamic Inventory**: Automatic GCP instance discovery using native cloud plugins
- **Zero-Touch Authentication**: OS Login and Service Account integration
- **Human-in-the-Loop**: Approval gates for production deployments
- **Secrets Management**: Vault integration for credential security
- **Idempotency**: Safe re-runs without duplication or errors
- **Audit Trail**: Full logging and notification capabilities

\newpage

## Prerequisites

### Required Collections and Versions
```bash
# Install required Ansible collections
ansible-galaxy collection install google.cloud:1.3.0+
ansible-galaxy collection install redhat.satellite:4.0.0+
ansible-galaxy collection install awx.awx:24.0.0+
ansible-galaxy collection install infra.controller_configuration:2.7.0+
```

### GCP Requirements
- GCP Project with Compute Engine API enabled
- Service Account with roles:
  - `roles/compute.viewer` (read instance metadata)
  - `roles/iam.serviceAccountUser` (OS Login integration)
- Service Account JSON key file downloaded

### Satellite 6.18 Requirements
- Satellite server accessible from AAP controller
- Organization and Location configured
- Activation Key created for GCP instances
- Host Group defined with appropriate Content View and Lifecycle Environment

### AAP 2.6 Requirements
- Ansible Automation Platform 2.6 installed and configured
- Execution Environment with required collections (see [Execution Environment](#execution-environment))
- Projects synchronized from SCM (Git)
- Credentials configured (see [Credentials Setup](#credentials-setup))

\newpage

## Architecture

### Workflow Overview

The integration follows a structured workflow from discovery to deployment:

1. **Discovery**: GCP dynamic inventory sync fetches running RHEL instances
2. **Validation**: Pre-flight checks verify SSH connectivity and prerequisites
3. **Approval**: Human approver reviews discovered instances
4. **Cleanup**: Remove Google RHUI packages to prevent conflicts
5. **Registration**: Install Katello consumer and register to Satellite
6. **Assignment**: Apply Host Group for lifecycle management
7. **Notification**: Send success/failure alerts to operations team

### Execution Flow

```
[GCP Instances] → [AAP 2.6 Inventory Sync] → [Approval Gate] → 
[Pre-Flight Checks] → [Registration Tasks] → [Satellite 6.18] → 
[Content Sync] → [Notifications]
```

\newpage

## Local Development Setup

### 1. Project Structure

Create the following directory structure:
```
RedHat_Management/
├── ansible.cfg
├── inventories/
│   └── gcp_dynamic.yml
├── playbooks/
│   └── gcp_satellite_registration.yml
├── group_vars/
│   └── all/
│       ├── vars.yml
│       └── vault.yml (encrypted)
├── roles/
│   └── gcp_satellite_register/
│       ├── defaults/main.yml
│       ├── tasks/main.yml
│       └── handlers/main.yml
└── execution_environments/
    └── ee_gcp_satellite.yml
```

### 2. Ansible Configuration (`ansible.cfg`)

```ini
[defaults]
# Inventory configuration
inventory = ./inventories/gcp_dynamic.yml
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
callbacks_enabled = profile_tasks, timer

# Vault configuration
vault_password_file = ~/.ansible/conf/.vault_pass.txt

# SSH optimization
pipelining = True
forks = 10
timeout = 30

# Logging
log_path = ./logs/ansible.log

[inventory]
# Enable GCP inventory plugin
enable_plugins = google.cloud.gcp_compute

[ssh_connection]
# GCP OS Login integration
ssh_args = -o ControlMaster=auto -o ControlPersist=300s -o StrictHostKeyChecking=no
control_path = ~/.ansible/cp/%%h-%%p-%%r

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

### 3. Dynamic Inventory Configuration (`inventories/gcp_dynamic.yml`)

```yaml
---
plugin: google.cloud.gcp_compute

# GCP Project Configuration
projects:
  - your-gcp-project-id

# Authentication
auth_kind: serviceaccount
service_account_file: ~/.gcp/service-account-key.json

# Scope to specific zones (optional)
zones:
  - us-central1-a
  - us-central1-b
  - us-east1-c

# Filter for running RHEL instances only
filters:
  - status = RUNNING
  - labels.os = rhel OR name ~ "rhel"

# Hostname configuration
hostnames:
  - name  # Use instance name as inventory hostname
  - private_ip  # Fallback to private IP

# Grouping strategy
keyed_groups:
  # Group by zone
  - key: zone
    prefix: gcp_zone
  # Group by machine type
  - key: machineType
    prefix: gcp_type
  # Group by labels
  - key: labels
    prefix: gcp_label
  # Group by network tags
  - key: tags.items
    prefix: gcp_tag

# Compose variables
compose:
  ansible_host: networkInterfaces[0].networkIP
  gcp_instance_id: id
  gcp_instance_name: name
  gcp_machine_type: machineType
  gcp_zone: zone
  gcp_status: status
  gcp_tags: tags.items | default([])
  gcp_labels: labels | default({})

# Enable caching for performance
cache: True
cache_plugin: jsonfile
cache_timeout: 3600
cache_connection: /tmp/gcp_inventory_cache
```

### 4. Secrets Management

#### Create Vault Password File
```bash
# Create secure directory
mkdir -p ~/.ansible/conf/
echo "your_vault_master_password" > ~/.ansible/conf/.vault_pass.txt
chmod 600 ~/.ansible/conf/.vault_pass.txt
```

#### Create Encrypted Variables (`group_vars/all/vault.yml`)
```bash
ansible-vault create group_vars/all/vault.yml
```

Content:
```yaml
---
# Satellite credentials
vault_satellite_username: admin
vault_satellite_password: YourSecretPassword

# GCP Service Account
vault_gcp_service_account_file: ~/.gcp/service-account-key.json

# AAP credentials (for export/import)
vault_aap_admin_password: AAPAdminPassword
```

#### Create Non-Encrypted Variables (`group_vars/all/vars.yml`)
```yaml
---
# Satellite configuration
satellite_url: https://satellite.example.com
satellite_organization: Default_Organization
satellite_location: Default_Location
satellite_hostgroup: GCP_RHEL_Production
satellite_activation_key: gcp-rhel-prod-key

# GCP configuration
gcp_project_id: your-gcp-project-id
gcp_region: us-central1

# RHEL version mapping
rhel_version_packages:
  '8': google-rhui-client-rhel8
  '9': google-rhui-client-rhel9

# Network configuration
satellite_verify_ssl: false
ssh_connection_timeout: 30
max_fail_percentage: 10
```

### 5. Registration Playbook (`playbooks/gcp_satellite_registration.yml`)

```yaml
---
- name: Register GCP RHEL Instances to Satellite 6.18
  hosts: all
  gather_facts: false
  serial: "{{ serial_execution | default(5) }}"
  max_fail_percentage: "{{ max_fail_percentage | default(10) }}"
  
  vars:
    satellite_url: "{{ satellite_url }}"
    satellite_username: "{{ vault_satellite_username }}"
    satellite_password: "{{ vault_satellite_password }}"
    satellite_organization: "{{ satellite_organization }}"
    satellite_location: "{{ satellite_location }}"
    satellite_hostgroup: "{{ satellite_hostgroup }}"
    satellite_activation_key: "{{ satellite_activation_key }}"

  pre_tasks:
    - name: Pre-flight - Verify SSH connectivity
      ansible.builtin.wait_for_connection:
        timeout: "{{ ssh_connection_timeout | default(30) }}"
        connect_timeout: 10
        delay: 5
      register: ssh_check
      ignore_unreachable: true
      tags: ['preflight', 'validate']

    - name: Pre-flight - Fail if host unreachable
      ansible.builtin.fail:
        msg: |
          Cannot establish SSH connection to {{ inventory_hostname }}
          Possible causes:
            - GCP firewall blocking port 22
            - SSH daemon not running
            - OS Login not configured
            - Service account lacks permissions
      when: ssh_check is unreachable
      tags: ['preflight', 'validate']

    - name: Pre-flight - Gather minimal facts
      ansible.builtin.setup:
        gather_subset:
          - '!all'
          - '!min'
          - network
          - distribution
      tags: ['preflight', 'validate']

    - name: Pre-flight - Validate OS is RHEL
      ansible.builtin.assert:
        that:
          - ansible_distribution == "RedHat"
          - ansible_distribution_major_version in ['7', '8', '9']
        fail_msg: "Host {{ inventory_hostname }} is not running RHEL 7/8/9"
        success_msg: "Validated {{ ansible_distribution }} {{ ansible_distribution_version }}"
      tags: ['preflight', 'validate']

  tasks:
    - name: Subscription - Clean existing subscription-manager data
      ansible.builtin.command:
        cmd: subscription-manager clean
      register: sub_clean_result
      changed_when: "'All local data removed' in sub_clean_result.stdout"
      failed_when: false
      tags: ['subscription', 'cleanup']

    - name: Cleanup - Detect GCP RHUI packages
      ansible.builtin.package_facts:
        manager: auto
      tags: ['cleanup', 'rhui']

    - name: Cleanup - Remove Google RHUI client packages
      ansible.builtin.dnf:
        name:
          - google-rhui-client-rhel{{ ansible_distribution_major_version }}
          - google-cloud-sdk
        state: absent
        disable_gpg_check: true
      when: 
        - ("google-rhui-client-rhel" + ansible_distribution_major_version) in ansible_facts.packages or
          "google-cloud-sdk" in ansible_facts.packages
      register: rhui_removal
      tags: ['cleanup', 'rhui']

    - name: Cleanup - Remove residual RHUI repository files
      ansible.builtin.file:
        path: "{{ item }}"
        state: absent
      loop:
        - /etc/yum.repos.d/google-cloud.repo
        - /etc/yum.repos.d/rh-cloud.repo
        - /etc/pki/rpm-gpg/google-cloud-public-key
      tags: ['cleanup', 'rhui']

    - name: Satellite - Download Katello CA consumer RPM
      ansible.builtin.get_url:
        url: "{{ satellite_url }}/pub/katello-ca-consumer-latest.noarch.rpm"
        dest: /tmp/katello-ca-consumer-latest.noarch.rpm
        mode: '0644'
        validate_certs: "{{ satellite_verify_ssl | default(false) }}"
        timeout: 30
      register: katello_download
      retries: 3
      delay: 10
      until: katello_download is success
      tags: ['satellite', 'registration']

    - name: Satellite - Install Katello CA consumer
      ansible.builtin.dnf:
        name: /tmp/katello-ca-consumer-latest.noarch.rpm
        state: present
        disable_gpg_check: true
      tags: ['satellite', 'registration']

    - name: Satellite - Register host using activation key
      community.general.redhat_subscription:
        state: present
        activationkey: "{{ satellite_activation_key }}"
        org_id: "{{ satellite_organization }}"
        force_register: true
      register: registration_result
      tags: ['satellite', 'registration']

    - name: Satellite - Enable required repositories
      community.general.rhsm_repository:
        name: "{{ item }}"
        state: enabled
      loop:
        - "rhel-{{ ansible_distribution_major_version }}-for-x86_64-baseos-rpms"
        - "rhel-{{ ansible_distribution_major_version }}-for-x86_64-appstream-rpms"
      when: registration_result is success
      tags: ['satellite', 'registration']

    - name: Satellite - Install katello-agent for remote actions
      ansible.builtin.dnf:
        name: katello-agent
        state: present
      when: ansible_distribution_major_version in ['7', '8']
      tags: ['satellite', 'tools']

  post_tasks:
    - name: Post-registration - Assign host to hostgroup via Satellite API
      delegate_to: localhost
      become: false
      ansible.builtin.uri:
        url: "{{ satellite_url }}/api/v2/hosts/{{ inventory_hostname }}"
        method: PUT
        user: "{{ satellite_username }}"
        password: "{{ satellite_password }}"
        body_format: json
        body:
          host:
            hostgroup_id: "{{ satellite_hostgroup }}"
            location_id: "{{ satellite_location }}"
            organization_id: "{{ satellite_organization }}"
            build: false
            managed: true
        validate_certs: "{{ satellite_verify_ssl | default(false) }}"
        status_code: [200, 201]
      register: hostgroup_assignment
      retries: 3
      delay: 5
      until: hostgroup_assignment is success
      tags: ['satellite', 'hostgroup']
      no_log: true

    - name: Post-registration - Verify registration status
      ansible.builtin.command:
        cmd: subscription-manager status
      register: sub_status
      changed_when: false
      tags: ['validate', 'verify']

    - name: Post-registration - Display subscription status
      ansible.builtin.debug:
        var: sub_status.stdout_lines
      tags: ['validate', 'verify']

  handlers:
    - name: Restart subscription-manager
      ansible.builtin.systemd:
        name: rhsmcertd
        state: restarted
```

\newpage

## AAP 2.6 Configuration

### 1. Execution Environment

Create a custom Execution Environment with all required dependencies.

#### Execution Environment Definition (`execution_environments/ee_gcp_satellite.yml`)

```yaml
---
version: 3

images:
  base_image:
    name: registry.redhat.io/ansible-automation-platform-26/ee-minimal-rhel9:latest

dependencies:
  galaxy:
    collections:
      - name: google.cloud
        version: ">=1.3.0"
      - name: redhat.satellite
        version: ">=4.0.0"
      - name: community.general
        version: ">=9.0.0"
      - name: awx.awx
        version: ">=24.0.0"
  
  python:
    - google-auth>=2.29.0
    - requests>=2.31.0
    - pytz>=2024.1

  system:
    - python3-libcloud [platform:rpm]
    - git-core [platform:rpm]

additional_build_steps:
  prepend_galaxy:
    - RUN pip3 install --upgrade pip setuptools
  
  append_final:
    - RUN chmod -R g=u /runner
    - RUN ansible-galaxy collection list

options:
  package_manager_path: /usr/bin/microdnf
  user: 1000
```

#### Build and Push Execution Environment

```bash
# Build the execution environment
ansible-builder build \
  --tag quay.io/your-org/ee-gcp-satellite:1.0.0 \
  --file execution_environments/ee_gcp_satellite.yml \
  --container-runtime podman \
  --verbosity 3

# Push to container registry
podman push quay.io/your-org/ee-gcp-satellite:1.0.0
```

### 2. Credentials Setup

Navigate to **Resources > Credentials** in AAP and create the following:

#### A. GCP Service Account Credential
- **Name**: `GCP Service Account - Production`
- **Credential Type**: `Google Compute Engine`
- **Service Account JSON**: Paste content of your GCP service account key file
- **Project**: `your-gcp-project-id`

#### B. Satellite API Credential
- **Name**: `Satellite 6.18 API Credential`
- **Credential Type**: `Red Hat Satellite 6`
- **Satellite 6 URL**: `https://satellite.example.com`
- **Username**: `admin`
- **Password**: `{{ vault_satellite_password }}`

#### C. Machine Credential (SSH)
- **Name**: `GCP SSH - OS Login`
- **Credential Type**: `Machine`
- **Username**: Your GCP OS Login username (e.g., `sa_117234567890123456789`)
- **SSH Private Key**: Leave empty if using OS Login, or paste private key
- **Privilege Escalation Method**: `sudo`

#### D. Vault Credential
- **Name**: `Ansible Vault - Secrets`
- **Credential Type**: `Vault`
- **Vault Password**: Your vault master password from `~/.ansible/conf/.vault_pass.txt`

### 3. Project Configuration

#### Create Project
1. Navigate to **Resources > Projects**
2. Click **Add**
3. **Name**: `GCP to Satellite Integration`
4. **Organization**: Your organization
5. **Execution Environment**: `ee-gcp-satellite:1.0.0`
6. **Source Control Type**: `Git`
7. **Source Control URL**: `https://github.com/your-org/RedHat_Management.git`
8. **Source Control Branch/Tag/Commit**: `main`
9. **Options**:
   - ✅ Update Revision on Launch
   - ✅ Clean
   - ✅ Delete on Update

### 4. Inventory Configuration

#### Create Inventory
1. Navigate to **Resources > Inventories**
2. Click **Add > Add inventory**
3. **Name**: `GCP Dynamic Inventory - Production`
4. **Organization**: Your organization

#### Add Inventory Source
1. Click the inventory you just created
2. Click the **Sources** tab
3. Click **Add**
4. **Name**: `GCP Compute Engine Source`
5. **Source**: `Google Compute Engine`
6. **Credential**: Select `GCP Service Account - Production`
7. **Execution Environment**: `ee-gcp-satellite:1.0.0`
8. **Source Variables**:

```yaml
---
plugin: google.cloud.gcp_compute
projects:
  - your-gcp-project-id
auth_kind: serviceaccount
filters:
  - status = RUNNING
  - labels.environment = production
hostnames:
  - name
keyed_groups:
  - prefix: gcp_zone
    key: zone
  - prefix: gcp_env
    key: labels.environment
compose:
  ansible_host: networkInterfaces[0].networkIP
```

9. **Options**:
   - ✅ Overwrite
   - ✅ Overwrite Variables
   - ✅ Update on Launch

### 5. Job Template Configuration

#### Create Job Template
1. Navigate to **Resources > Templates**
2. Click **Add > Add job template**
3. Configure as follows:

**Basic Settings**:
- **Name**: `Register GCP Instances to Satellite`
- **Job Type**: `Run`
- **Inventory**: `GCP Dynamic Inventory - Production`
- **Project**: `GCP to Satellite Integration`
- **Execution Environment**: `ee-gcp-satellite:1.0.0`
- **Playbook**: `playbooks/gcp_satellite_registration.yml`

**Credentials** (add all four):
- `GCP Service Account - Production`
- `GCP SSH - OS Login`
- `Satellite 6.18 API Credential`
- `Ansible Vault - Secrets`

**Options**:
- ✅ Enable Privilege Escalation
- ✅ Enable Fact Storage
- ✅ Enable Concurrent Jobs
- ✅ Enable Webhooks (optional)

**Advanced Settings**:
- **Forks**: `10`
- **Job Slicing**: `5` (for large inventories)
- **Timeout**: `1800` (30 minutes)
- **Show Changes**: ✅

**Extra Variables**:
```yaml
---
serial_execution: 5
max_fail_percentage: 10
ssh_connection_timeout: 30
```

\newpage

## Workflow Implementation

### 1. Create Workflow Template

1. Navigate to **Resources > Templates**
2. Click **Add > Add workflow template**
3. **Name**: `GCP to Satellite - Automated Registration Workflow`
4. **Organization**: Your organization
5. **Inventory**: `GCP Dynamic Inventory - Production`
6. Click **Save**

### 2. Build Workflow in Visualizer

The workflow visualizer will open automatically. Build the following node structure:

#### Node 1: Inventory Sync
- **Type**: `Inventory Source Sync`
- **Inventory Source**: `GCP Compute Engine Source`
- **Convergence**: `Any`

#### Node 2: Approval Gate
- **Type**: `Approval`
- **Name**: `Approve GCP Instance Registration`
- **Description**: `Review discovered GCP instances before Satellite registration`
- **Timeout**: `3600` (1 hour)
- **Link from**: Node 1 (on success - green line)

#### Node 3: Registration Job
- **Type**: `Job Template`
- **Job Template**: `Register GCP Instances to Satellite`
- **Link from**: Node 2 (on success - green line)

#### Node 4: Success Notification (optional)
- **Type**: `Notification Template`
- **Notification Template**: `GCP Registration Success Alert`
- **Link from**: Node 3 (on success - green line)

#### Node 5: Failure Notification (optional)
- **Type**: `Notification Template`
- **Notification Template**: `GCP Registration Failure Alert`
- **Link from**: Node 3 (on failure - red line)

### 3. Configure Notifications

#### Create Slack Notification
1. Navigate to **Administration > Notifier**
2. Click **Add**
3. **Name**: `GCP Registration Approval Alert`
4. **Organization**: Your organization
5. **Type**: `Slack`
6. **Credentials**:
   - **Webhook URL**: Your Slack webhook URL
7. **Channels**: `#infrastructure-alerts`
8. **Messages to Send**:
   - ✅ Workflow Approval
   - ✅ Workflow Job Success
   - ✅ Workflow Job Failure

#### Customize Messages

**Approval Message**:
```text
🔔 *GCP to Satellite Registration Workflow*

*Status:* Awaiting Approval
*Inventory:* {{ inventory_name }}
*Discovered Hosts:* {{ inventory_total_hosts }}

Please review and approve the registration of discovered GCP instances.

{{ workflow_approval_url }}
```

**Success Message**:
```text
✅ *GCP Registration Complete*

*Workflow:* {{ workflow_job_template_name }}
*Hosts Registered:* {{ job_successful_count }}
*Duration:* {{ job_elapsed }}

All GCP instances have been successfully registered to Satellite 6.18.
```

**Failure Message**:
```text
❌ *GCP Registration Failed*

*Workflow:* {{ workflow_job_template_name }}
*Failed Hosts:* {{ job_failed_count }}
*Error:* {{ job_result_stdout | truncate(200) }}

{{ workflow_url }}
```

### 4. Assign Approval Permissions

1. Navigate to your Workflow Template
2. Click the **Access** tab
3. Click **Add**
4. Select the user or team
5. Assign the **Approve** role

\newpage

## Execution and Operations

### 1. Manual Workflow Execution

1. Navigate to **Resources > Templates**
2. Find `GCP to Satellite - Automated Registration Workflow`
3. Click the **Launch** button
4. **Phase 1**: Inventory sync runs automatically
5. **Phase 2**: Workflow pauses at approval node
6. **Phase 3**: Approver receives notification and reviews
7. **Phase 4**: After approval, registration playbook executes
8. **Phase 5**: Notification sent on completion

### 2. Scheduled Execution

1. Open the Workflow Template
2. Click the **Schedules** tab
3. Click **Add**
4. **Name**: `Daily GCP Discovery and Registration`
5. **Start Date/Time**: Select date and time
6. **Local Time Zone**: Your timezone
7. **Repeat Frequency**: `Daily`
8. **Repeat Every**: `1` day
9. **On Days**: Select days (e.g., Monday-Friday)
10. **End**: `Never` or select end date

### 3. API-Driven Execution

```bash
# Launch workflow via AAP API
curl -X POST \
  -H "Authorization: Bearer YOUR_AAP_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "extra_vars": {
      "serial_execution": 10,
      "max_fail_percentage": 5
    }
  }' \
  https://your-aap-url.example.com/api/v2/workflow_job_templates/123/launch/
```

### 4. Monitoring and Reporting

#### View Job Output
1. Navigate to **Views > Jobs**
2. Click on the workflow job
3. Review the **Details** tab for overall status
4. Click individual nodes to see detailed output
5. Use **Output** tab for real-time logs

#### Export Job Run Data

```bash
# Export workflow results to JSON
curl -H "Authorization: Bearer YOUR_AAP_API_TOKEN" \
  https://your-aap-url.example.com/api/v2/workflow_jobs/456/ \
  > workflow_results.json
```

\newpage

## Troubleshooting and Validation

### Common Issues and Resolutions

#### Issue 1: GCP Inventory Sync Fails

**Symptoms**:
```
Authentication error: Service account credentials invalid
```

**Resolution**:
1. Verify GCP service account has required roles:
   ```bash
   gcloud projects get-iam-policy your-gcp-project-id \
     --flatten="bindings[].members" \
     --filter="bindings.members:serviceAccount:your-sa@project.iam.gserviceaccount.com"
   ```
2. Ensure Compute Engine API is enabled:
   ```bash
   gcloud services enable compute.googleapis.com --project=your-gcp-project-id
   ```
3. Verify JSON key file is valid and not expired

#### Issue 2: SSH Connection Failures

**Symptoms**:
```
Failed to connect to the host via ssh: Permission denied (publickey)
```

**Resolution**:
1. Verify OS Login is configured:
   ```bash
   gcloud compute project-info describe --project=your-gcp-project-id \
     --format="value(commonInstanceMetadata.items.filter(key:enable-oslogin))"
   ```
2. Add yourself to OS Login:
   ```bash
   gcloud compute os-login ssh-keys add \
     --key-file=~/.ssh/id_rsa.pub \
     --project=your-gcp-project-id
   ```
3. Verify firewall allows SSH from AAP controller IP

#### Issue 3: Satellite Registration Fails

**Symptoms**:
```
Unable to register system to Satellite: Invalid activation key
```

**Resolution**:
1. Verify activation key exists:
   ```bash
   hammer activation-key list \
     --organization "Default_Organization"
   ```
2. Check activation key has correct subscriptions attached
3. Verify Satellite host group and lifecycle environment are configured
4. Ensure katello-ca-consumer RPM is accessible

#### Issue 4: Host Group Assignment Fails

**Symptoms**:
```
HTTP 404: Host not found in Satellite
```

**Resolution**:
1. Add delay before hostgroup assignment (registration propagation):
   ```yaml
   - name: Wait for Satellite to process registration
     ansible.builtin.pause:
       seconds: 30
     delegate_to: localhost
   ```
2. Verify hostname in Satellite matches `inventory_hostname`
3. Use Satellite API to search for host:
   ```bash
   curl -u admin:password \
     https://satellite.example.com/api/v2/hosts?search=name=instance-name
   ```

### Validation Checklist

After successful workflow execution, validate the following:

- [ ] GCP inventory sync completed without errors
- [ ] All expected instances appear in AAP inventory
- [ ] Approval notification was received
- [ ] SSH pre-flight checks passed for all hosts
- [ ] Google RHUI packages removed successfully
- [ ] Katello CA consumer installed on all hosts
- [ ] Hosts registered to Satellite organization
- [ ] Correct subscriptions attached and enabled
- [ ] Host group assigned in Satellite
- [ ] Hosts appear in Satellite web UI under **Hosts > All Hosts**
- [ ] Content view and lifecycle environment applied correctly
- [ ] Success notification received

### Debug Mode Execution

Run playbook with maximum verbosity for troubleshooting:

```bash
# From CLI (local development)
ansible-playbook playbooks/gcp_satellite_registration.yml \
  -i inventories/gcp_dynamic.yml \
  --limit instance-name \
  -vvvv \
  --step

# From AAP (add to Extra Variables)
ansible_verbosity: 4
```

\newpage

## Best Practices and Recommendations

### Security
- **Never commit unencrypted credentials** to version control
- Use **AAP credential injection** instead of storing secrets in playbooks
- Enable **audit logging** in AAP for compliance
- Rotate **service account keys** every 90 days
- Use **least privilege** principle for GCP service accounts
- Enable **MFA** for AAP approvers

### Performance
- Use **job slicing** for inventories with >100 hosts
- Implement **serial execution** to prevent overwhelming Satellite API
- Cache GCP inventory (3600s) to reduce API calls
- Use **forks** setting appropriate to your infrastructure

### Reliability
- Set reasonable **timeout values** for network operations
- Implement **retry logic** for transient failures
- Use **max_fail_percentage** to allow partial failures
- Enable **fact caching** to speed up subsequent runs

### Operations
- **Schedule** workflows during maintenance windows
- Implement **change management** approval processes
- Maintain **runbooks** for common failure scenarios
- Setup **monitoring** and alerting for failed jobs
- Keep **execution environments** updated with latest collections

\newpage

## Configuration as Code

### Export AAP Configuration

Use `infra.controller_configuration` collection to export and version control your AAP setup:

```yaml
---
- name: Export AAP 2.6 Configuration
  hosts: localhost
  connection: local
  gather_facts: false

  vars:
    controller_hostname: aap-controller.example.com
    controller_username: admin
    controller_password: "{{ vault_aap_admin_password }}"
    controller_validate_certs: false

  tasks:
    - name: Export all configurations
      include_role:
        name: infra.controller_configuration.dispatch
      vars:
        controller_configuration_dispatcher_roles:
          - {role: settings, var: controller_settings, tags: settings}
          - {role: organizations, var: controller_organizations, tags: organizations}
          - {role: credentials, var: controller_credentials, tags: credentials}
          - {role: credential_types, var: controller_credential_types, tags: credential_types}
          - {role: inventories, var: controller_inventories, tags: inventories}
          - {role: inventory_sources, var: controller_inventory_sources, tags: inventory_sources}
          - {role: projects, var: controller_projects, tags: projects}
          - {role: job_templates, var: controller_job_templates, tags: job_templates}
          - {role: workflow_job_templates, var: controller_workflows, tags: workflow}
          - {role: notification_templates, var: controller_notifications, tags: notifications}
          - {role: schedules, var: controller_schedules, tags: schedules}

    - name: Save configuration to file
      ansible.builtin.copy:
        content: "{{ vars | to_nice_yaml }}"
        dest: "./aap_config_backup_{{ ansible_date_time.date }}.yml"
        mode: '0600'
```

### Project Structure Summary

```
RedHat_Management/
├── ansible.cfg                          # Ansible configuration
├── inventories/
│   └── gcp_dynamic.yml                  # GCP dynamic inventory
├── playbooks/
│   ├── gcp_satellite_registration.yml   # Main registration playbook
│   └── export_aap_config.yml            # AAP config export
├── group_vars/
│   └── all/
│       ├── vars.yml                     # Non-sensitive variables
│       └── vault.yml                    # Encrypted credentials
├── roles/
│   └── gcp_satellite_register/          # Custom role (optional)
├── execution_environments/
│   └── ee_gcp_satellite.yml             # EE definition
├── collections/
│   └── requirements.yml                 # Collection dependencies
└── docs/
    └── Ansible_Automation_Platform_working_seamlessly_with_GCP.md
```

\newpage

## Summary

This production-ready integration provides:

✅ **Automated Discovery**: GCP instances automatically discovered via dynamic inventory  
✅ **Human Approval**: Gated workflow ensures production safety  
✅ **Robust Error Handling**: Pre-flight checks and retry logic  
✅ **Secure Secrets**: Vault integration and AAP credential injection  
✅ **Full Observability**: Notifications, logging, and audit trails  
✅ **Idempotent Operations**: Safe to re-run without side effects  
✅ **AAP 2.6 Native**: Leverages latest platform features (EE, workflow approval, RBAC)  
✅ **Satellite 6.18 Compliant**: Uses modern registration APIs and host group management  

The workflow is designed for enterprise scale, handling hundreds of GCP instances with proper error handling, human oversight, and complete audit trails.

For questions or issues, refer to:
- [Red Hat Ansible Automation Platform Documentation](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.6)
- [Google Cloud Ansible Collection](https://docs.ansible.com/ansible/latest/collections/google/cloud/)
- [Red Hat Satellite 6.18 Documentation](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.18)
