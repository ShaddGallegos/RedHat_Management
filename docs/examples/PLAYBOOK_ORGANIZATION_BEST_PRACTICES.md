# Playbook Organization Best Practices

Complete guide for organizing playbooks using tags, scenarios, and platforms with best practices.

## Architecture Decision: Tags vs Individual Playbooks

### ✅ Recommended Approach: Unified Playbook with Tags

**Benefits:**
- Single source of truth for deployment logic
- Shared variables and configurations
- Consistent error handling
- Easier maintenance and updates
- Better orchestration of dependencies
- Reduced code duplication
- Clear execution flow

**When to use:**
- Most deployments (85% of use cases)
- Scenarios with shared setup/teardown
- Complex multi-component deployments
- When order of execution matters

### ⚠️ Alternative: Individual Playbooks

**Use only when:**
- Components are completely independent
- Different teams manage different playbooks
- Playbooks need to run on completely different infrastructure
- Playbook complexity exceeds 500 lines

## Tag-Based Execution Strategy

### Tag Hierarchy

```
scenario tags
└── platform tags
    └── os tags
        └── component tags
            └── task tags
```

### Example Tag Structure

```yaml
# Scenario tags (top level)
- "satellite_only"
- "aap_only"
- "full_stack"

# Platform tags (selects infrastructure)
- "libvirt"
- "aws"
- "azure"
- "baremetal"

# OS tags (selects operating system)
- "rhel-9"
- "rhel-10"

# Component tags (specific products)
- "satellite"
- "aap"
- "idm"
- "openshift"

# Feature tags (specific features)
- "networking"
- "storage"
- "integration"
- "monitoring"

# Task tags (granular control)
- "install"
- "configure"
- "validate"
- "backup"
```

## Execution Examples

### Single Scenario + Platform

Run Satellite-only on AWS:
```bash
ansible-playbook redhat_management-site.yml \
  --tags "satellite_only,aws,rhel-9"
```

### Full Stack on LibVirt

Deploy complete platform:
```bash
ansible-playbook redhat_management-site.yml \
  --tags "full_stack,libvirt,rhel-9"
```

### Only Install (Skip Configuration)

Install all components without configuration:
```bash
ansible-playbook redhat_management-site.yml \
  --tags "install"
```

### Skip Monitoring Setup

Deploy without monitoring:
```bash
ansible-playbook redhat_management-site.yml \
  --tags "satellite_aap,libvirt,rhel-9" \
  --skip-tags "monitoring"
```

### Validate Only

Run only validation tasks:
```bash
ansible-playbook redhat_management-site.yml \
  --tags "validate" \
  --skip-tags "install,configure"
```

## Playbook Structure

### Main Orchestration Playbook (site.yml)

```yaml
---
- name: RHIS - Unified Deployment
  hosts: localhost
  gather_facts: yes
  
  # Phase 1: Setup
  - name: Setup Phase
    block:
      - include_tasks: setup/validate.yml
      - include_tasks: setup/preflight.yml
    tags: ["setup", "always"]
  
  # Phase 2: Infrastructure Preparation
  - name: Infrastructure Preparation
    block:
      - include_tasks: infrastructure/libvirt.yml
        when: deployment_platform == "libvirt"
      - include_tasks: infrastructure/aws.yml
        when: deployment_platform == "aws"
    tags: ["infrastructure"]
  
  # Phase 3: Component Deployment
  - name: Deploy Satellite
    include_tasks: components/satellite/deploy.yml
    when: "'satellite' in deployment_components"
    tags: ["satellite", "install"]
  
  - name: Deploy AAP
    include_tasks: components/aap/deploy.yml
    when: "'aap' in deployment_components"
    tags: ["aap", "install"]
  
  # Phase 4: Integration
  - name: Configure Integrations
    block:
      - include_tasks: integration/satellite_aap.yml
        when: "'satellite' in deployment_components and 'aap' in deployment_components"
    tags: ["integration"]
  
  # Phase 5: Validation
  - name: Validate Deployment
    include_tasks: validation/all.yml
    tags: ["validate"]
```

## Variable Management

### Precedence Order (Highest to Lowest)

1. Command-line extra vars: `-e deployment_scenario=satellite_only`
2. Play-level vars_files
3. Group variables (group_vars/all.yml)
4. Host variables (host_vars/)
5. Role defaults
6. Environment lookups
7. Defaults in playbook

### Variable Structure Example

```yaml
# Define at play level
vars:
  # Scenario selection
  deployment_scenario: "satellite_aap"
  deployment_platform: "libvirt"
  deployment_os: "rhel-9"
  
  # Derived variables
  deployment_components: "{{ scenarios[deployment_scenario].components }}"
  platform_config: "{{ platforms[deployment_platform] }}"
  
  # Credentials
  vars_files:
    - "{{ lookup('first_found', credential_files) }}"

# Include group variables
vars_files:
  - group_vars/all.yml
  - group_vars/{{ deployment_platform }}.yml
```

## Best Practices

### 1. Modular Task Organization

**Good:**
```yaml
- name: Deploy Satellite
  block:
    - include_tasks: satellite/install.yml
      tags: ["install"]
    - include_tasks: satellite/configure.yml
      tags: ["configure"]
    - include_tasks: satellite/validate.yml
      tags: ["validate"]
  tags: ["satellite"]
```

**Avoid:**
```yaml
- name: Deploy Satellite
  block:
    - name: Install
      yum: name=satellite
    - name: Configure
      template: src=satellite.j2
    - name: Validate
      command: satellite-health-check
```

### 2. Use Include_Tasks with When Conditions

**Good:**
```yaml
- name: Deploy Based on Scenario
  include_tasks: "{{ deployment_scenario }}/deploy.yml"
  when: deployment_scenario is defined
  tags: ["deploy"]
```

**Avoid:**
```yaml
- block:
    - include: scenario1/deploy.yml
    - include: scenario2/deploy.yml
    - include: scenario3/deploy.yml
```

### 3. Conditional Tagging

**Good:**
```yaml
- name: Setup Monitoring
  include_tasks: monitoring/setup.yml
  tags: 
    - "{{ deployment_platform }}"
    - "monitoring"
    - "{{ 'full_stack' if deployment_scenario == 'full_stack' else 'omit' }}"
```

### 4. Proper Error Handling

**Good:**
```yaml
- name: Validate Requirements
  block:
    - name: Check ansible version
      assert:
        that:
          - ansible_version.full is version_compare('2.10', '>=')
    - name: Validate scenario selection
      assert:
        that:
          - deployment_scenario in supported_scenarios
  tags: ["validate", "always"]
```

### 5. Documented Tag Usage

```yaml
# Each task/block should document its tags
- name: Install Satellite Packages
  yum:
    name: satellite
  tags:
    - satellite         # Component tag
    - install           # Phase tag
    - rhel-9            # OS tag
    - "{{ deployment_platform }}"  # Platform tag
  
  # Documentation comment
  # This task: Installs Satellite 6.18 packages
  # Will run with: --tags "satellite,install"
  # Skipped with: --skip-tags "install"
```

## Variable Organization

### Credential Hierarchy

```
env.yml (vault-encrypted)
├── Global Credentials
│   ├── admin_password
│   ├── rhsm_username/password
│   └── offline_token
├── Service Credentials
│   ├── aap_admin_password
│   ├── satellite_admin_password
│   ├── idm_admin_password
│   └── eda_password
└── Integration Credentials
    ├── servicenow_api_token
    ├── aws_access_key
    └── vmware_password
```

### Configuration Hierarchy

```
group_vars/
├── all.yml (shared)
├── libvirt.yml (platform-specific)
├── aws.yml (platform-specific)
├── satellite.yml (component-specific)
├── aap.yml (component-specific)
└── idm.yml (component-specific)
```

## Execution Flow Diagram

```
Start
  │
  ├─→ [setup] Validate prerequisites
  │     └─→ [verify] Check ansible, python, packages
  │
  ├─→ [interactive] Prompt for scenario/platform
  │     └─→ Save configuration
  │
  ├─→ [preflight] Run pre-deployment checks
  │     └─→ [validate] Verify configuration
  │
  ├─→ [infrastructure] Prepare infrastructure
  │     ├─→ [libvirt] Setup KVM VMs
  │     ├─→ [aws] Setup EC2 instances
  │     └─→ [azure] Setup Azure VMs
  │
  ├─→ [install] Install components
  │     ├─→ [satellite] Install Satellite 6.18
  │     ├─→ [aap] Install AAP 2.6
  │     └─→ [idm] Install IdM 3.0
  │
  ├─→ [configure] Configure components
  │     ├─→ [satellite-configure] Configure Satellite
  │     ├─→ [aap-configure] Configure AAP
  │     └─→ [idm-configure] Configure IdM
  │
  ├─→ [integration] Configure integrations
  │     ├─→ [satellite-aap] Satellite ↔ AAP
  │     ├─→ [satellite-idm] Satellite ↔ IdM
  │     └─→ [aap-idm] AAP ↔ IdM
  │
  ├─→ [monitoring] Setup monitoring
  │     ├─→ [prometheus] Setup metrics collection
  │     └─→ [grafana] Setup dashboards
  │
  ├─→ [backup] Configure backups
  │     └─→ [backup-setup] Setup backup procedures
  │
  └─→ [validate] Validate deployment
        ├─→ [health-check] Component health checks
        └─→ [integration-test] Integration tests
End
```

## Running Specific Scenarios

### Scenario 1: Satellite Only (Quickest)
```bash
# Interactive
ansible-playbook playbooks/prompts_and_config.yml

# Direct
ansible-playbook redhat_management-site.yml \
  --tags "satellite_only,libvirt,rhel-9"
```

### Scenario 2: Satellite + AAP (Common)
```bash
ansible-playbook redhat_management-site.yml \
  --tags "satellite_aap,libvirt,rhel-9" \
  -e "deployment_scenario=satellite_aap"
```

### Scenario 3: Full Stack (Complete)
```bash
ansible-playbook redhat_management-site.yml \
  --tags "full_stack,aws,rhel-9" \
  -e "deployment_platform=aws" \
  -e "deployment_os=rhel-9"
```

### Scenario 4: Validation Only
```bash
ansible-playbook playbooks/redhat_management-site.yml \
  --tags "validate"
```

### Scenario 5: Install + Configure (Skip Monitoring)
```bash
ansible-playbook playbooks/redhat_management-site.yml \
  --tags "install,configure" \
  --skip-tags "monitoring,backup"
```

## Troubleshooting Tag Execution

### List all available tags
```bash
ansible-playbook playbooks/redhat_management-site.yml \
  --list-tags
```

### Dry-run with specific tags
```bash
ansible-playbook playbooks/redhat_management-site.yml \
  --tags "satellite" \
  --check
```

### Debug tag matching
```bash
ansible-playbook playbooks/redhat_management-site.yml \
  --tags "satellite" \
  -vvv  # Verbose output shows tag matching
```

## Migration Guide: From Individual to Unified Playbooks

If you have separate playbooks, consolidate them:

### Before (3 separate playbooks)
```
playbooks/
├── deploy_satellite.yml
├── deploy_aap.yml
└── deploy_idm.yml

# Run them manually in order
ansible-playbook deploy_satellite.yml
ansible-playbook deploy_aap.yml
ansible-playbook deploy_idm.yml
```

### After (1 unified playbook)
```
playbooks/
└── redhat_management-site.yml

# Run with tags
ansible-playbook redhat_management-site.yml --tags "satellite,aap,idm"
```

## Documentation

See also:
- [docs/deployment/OVERVIEW.md](../deployment/OVERVIEW.md) - Deployment scenarios
- [docs/reference/QUICK_REFERENCE.md](../reference/QUICK_REFERENCE.md) - Quick command reference
- [docs/examples/JINJA2_VARIABLES_REFERENCE.yml](./JINJA2_VARIABLES_REFERENCE.yml) - Variable reference

