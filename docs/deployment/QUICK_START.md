# RHIS Quick Start Guide

## Overview

The RedHat Infrastructure Standard (RHIS) Installer provides a complete, production-ready deployment automation framework for deploying and integrating Red Hat products:

- **Satellite 6.18** - Systems management and platform_provisioning
- **Ansible Automation Platform 2.6** - Automation and ansible_dev_node_orchestration  
- **Red Hat Identity Management 3.0** - Identity and access management
- **OpenShift 4.21+** - Container ansible_dev_node_orchestration

## Quick Start

### 1. Initial Setup

```bash
cd ~/Downloads/RedHat_Management

# Make installer executable
chmod +x RHIS-Installer-Enhanced.sh

# View help
./RHIS-Installer-Enhanced.sh --help
```

### 2. Run Interactive Installer

```bash
# Start interactive deployment wizard
./RHIS-Installer-Enhanced.sh

# Follow ansible_dev_node_prompts:
# 1. Enter Red Hat CDN credentials
# 2. Enter Red Hat Offline Token
# 3. Select deployment scenario (1-15)
# 4. Select platform (1-7)
# 5. Select OS (RHEL 9 or RHEL 10)
# 6. Confirm configuration
# 7. Deployment begins automatically
```

### 3. Deployment Scenarios (Choose One)

**Single Products:**
- 1: Satellite Only
- 2: AAP Only
- 3: IdM Only
- 4: OpenShift Only

**Dual Products:**
- 5: Satellite + AAP
- 6: Satellite + IdM
- 7: Satellite + OpenShift
- 8: AAP + IdM
- 9: AAP + OpenShift
- 10: IdM + OpenShift

**Triple Products:**
- 11: Satellite + AAP + IdM
- 12: Satellite + AAP + OpenShift
- 13: Satellite + IdM + OpenShift
- 14: AAP + IdM + OpenShift

**Full Stack (DEFAULT):**
- 15: Satellite + AAP + IdM + OpenShift

### 4. Platforms (Choose One)

- 1: LibVirt (KVM) - Development/Testing
- 2: Bare Metal - Physical servers
- 3: AWS - Amazon Web Services
- 4: Azure - Microsoft Azure
- 5: GCP - Google Cloud Platform
- 6: VMware - VMware vSphere
- 7: Nutanix - Nutanix HCI

### 5. Credential Management

Credentials are securely stored in:

```
~/.ansible/conf/env.yml (vault-encrypted)
```

Required credentials:
- Red Hat CDN Username (for all redhat.com/redhat.io domains)
- Red Hat CDN Password
- Red Hat Offline Token (for console.redhat.com/Automation Hub)

## Advanced Usage

### Command-Line Arguments

```bash
# Specify scenario
./RHIS-Installer-Enhanced.sh --scenario full_stack

# Specify platform
./RHIS-Installer-Enhanced.sh --platform libvirt

# Specify OS
./RHIS-Installer-Enhanced.sh --os_generic rhel-9

# Skip ansible_dev_node_prompts (requires --scenario, --platform, --os_generic)
./RHIS-Installer-Enhanced.sh --scenario full_stack --platform libvirt --os_generic rhel-9 --skip-ansible_dev_node_prompts
```

### Direct Playbook Execution

```bash
# Run specific scenario and platform
cd ~/Downloads/RedHat_Management

ansible-playbook playbooks/ansible_dev_node_orchestration.yml \
  -e "deployment_scenario=full_stack" \
  -e "deployment_platform=libvirt" \
  -e "deployment_os=rhel-9" \
  -i inventory/hosts

# Use tags for selective execution
ansible-playbook playbooks/ansible_dev_node_orchestration.yml \
  --tags "scenario_satellite,aap,idm,libvirt,rhel-9,install,configure" \
  -i inventory/hosts

# Skip certain phases
ansible-playbook playbooks/ansible_dev_node_orchestration.yml \
  --tags "install,configure,integrate" \
  --skip-tags "scenario_openshift" \
  -i inventory/hosts
```

## Directory Structure

```
RedHat_Management/
├── RHIS-Installer-Enhanced.sh    ← NEW: Enhanced installer with menus
├── RHIS-Installer.sh             ← Original installer (backup)
├── playbooks/
│   ├── ansible_dev_node_orchestration.yml         ← Main ansible_dev_node_orchestration playbook
│   ├── scenario_configs.yml      ← Scenario definitions
│   └── ...                         (other playbooks)
├── roles/
│   ├── installer_host/           ← Ansible developer node setup
│   ├── platform_prep/            ← Platform preparation
│   ├── ansible_dev_node_inventory_generator/      ← Inventory generation
│   ├── platform_libvirt_vm_provisioner/  ← VM platform_provisioning
│   ├── platform_infrastructure_manager/   ← Cloud platform_infrastructure_core
│   ├── ansible_dev_node_redhat_products/          ← Product deployment
│   ├── scenario_ansible_cmdb_core/                     ← Ansible-CMDB setup
│   ├── integration_generic/              ← Product integrations
│   └── ansible_dev_node_support/                  ← Utilities
├── group_vars/
│   ├── all.yml                   ← Global variables
│   ├── scenario_satellite.yml             ← Satellite-specific
│   ├── aap.yml                   ← AAP-specific
│   ├── idm.yml                   ← IdM-specific
│   ├── scenario_openshift.yml             ← OpenShift-specific
│   └── [platform].yml            ← Platform-specific
├── templates/
│   ├── ansible.cfg.j2            ← Ansible config template
│   ├── oemdrv/                   ← OEMDRV kickstart templates
│   └── repo-enable/              ← Repo enablement scripts
├── files/
│   ├── OEMDRV/                   ← OEMDRV kickstart files
│   ├── rhel-iso/                 ← RHEL ISO location
│   └── tftp/                     ← TFTP boot files
├── inventory/
│   ├── hosts                     ← Generated inventory
│   └── generated/                ← Dynamic inventory
├── docs/
│   ├── deployment/
│   │   ├── RHIS_DEPLOYMENT_ARCHITECTURE.md
│   │   └── README.md
│   ├── platforms/                ← Platform guides
│   ├── products/                 ← Product guides
│   └── examples/
└── logs/
    └── deployment_*.log          ← Deployment logs
```

## Deployment Workflow

### Phase 1: Initialization
- Collect credentials
- Setup Ansible developer node
- Validate prerequisites

### Phase 2: Infrastructure Preparation  
- Platform-specific setup
- Network configuration
- Installation method preparation

### Phase 3: Inventory Generation
- Build dynamic inventory
- Configure hosts
- Validate connectivity

### Phase 4: Product Deployment
- Deploy Satellite (if selected)
- Deploy AAP (if selected)
- Deploy IdM (if selected)
- Deploy OpenShift (if selected)

### Phase 5: Integration Configuration
- Configure inter-product integrations
- Setup authentication/authorization
- Enable data sharing

### Phase 6: Ansible-CMDB Setup
- Install Ansible-CMDB
- Configure dashboard
- Populate with inventory facts

### Phase 7: Validation & Verification
- Health checks
- Integration tests
- Generate deployment report

## Configuration Files

### Credentials (Vault-Encrypted)
```
~/.ansible/conf/env.yml
- redhat_cdn_username
- redhat_cdn_password
- redhat_offline_token
- (Additional credentials as needed)
```

### Deployment Configuration  
```
~/.ansible/conf/deployment_config.yml
- scenario: (selected scenario)
- platform: (selected platform)
- os_generic: (selected OS)
- install_method: (oemdrv or tftp)
- generated_date: (ISO 8601 timestamp)
```

## Accessing Deployed Products

After successful deployment:

```
Satellite:     https://scenario_satellite-hostname/
AAP:           https://aap-controller:443/
IdM:           https://idm-hostname/ipa/ui/
OpenShift:     https://console-scenario_openshift-console.apps.ocp/
Ansible-CMDB:  http://scenario_satellite-hostname:8081/
```

## Troubleshooting

### View Deployment Logs
```bash
tail -f logs/deployment_*.log
```

### Re-run Specific Phase
```bash
# Re-run scenario_satellite deployment only
ansible-playbook playbooks/ansible_dev_node_orchestration.yml \
  --tags "phase4a,scenario_satellite" \
  -i inventory/hosts
```

### Skip Specific Product
```bash
# Deploy everything except OpenShift
ansible-playbook playbooks/ansible_dev_node_orchestration.yml \
  --skip-tags "scenario_openshift" \
  -i inventory/hosts
```

## Documentation

- Full architecture: `docs/deployment/RHIS_DEPLOYMENT_ARCHITECTURE.md`
- Playbook reference: `docs/examples/PLAYBOOK_ORGANIZATION_BEST_PRACTICES.md`
- Variable reference: `docs/examples/JINJA2_VARIABLES_REFERENCE.yml`
- Platform guides: `docs/platforms/`
- Product guides: `docs/products/`

## Support

For issues, refer to:
- Logs in `logs/deployment_*.log`
- Documentation in `docs/`
- Troubleshooting guides in `docs/troubleshooting/`

## Version Information

- RHIS Version: 1.0.0
- Installer Version: 1.0
- Satellite: 6.18
- AAP: 2.6
- IdM: 3.0
- OpenShift: 4.21+

