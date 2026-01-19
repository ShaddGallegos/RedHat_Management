# RHIS Deployment Architecture

## Overview

The RedHat Infrastructure Standard (RHIS) uses a modular, tag-based deployment approach with clear separation of concerns across scenarios, platforms, and products.

## Deployment Flow

```
Installer Script
      ↓
Credential Collection (CDN, Token, SSH Keys)
      ↓
Scenario Selection (15 options)
      ↓
Platform Selection (7 options)
      ↓
OS Selection (RHEL 9/10)
      ↓
Installation Method (OEMDRV/TFTP)
      ↓
Configuration Review & Confirmation
      ↓
Deployment Initialization
      ├→ Ansible Developer Node Setup
      ├→ Platform Infrastructure Preparation
      ├→ Inventory Generation
      └→ Credential Management
      ↓
Product Deployment (in order)
      ├→ Satellite 6.18 Installation & Configuration
      ├→ AAP 2.6 Installation & Configuration
      ├→ IdM 3.0 Installation & Configuration
      └→ OpenShift Latest Installation & Configuration
      ↓
Integration Configuration
      ├→ Satellite ↔ AAP Integration
      ├→ Satellite ↔ IdM Integration
      ├→ AAP ↔ IdM Integration
      ├→ AAP → OpenShift Integration
      └→ Ansible-CMDB Setup (Port 8081)
      ↓
Post-Deployment Validation
      ├→ Health Checks
      ├→ Integration Tests
      ├→ Connectivity Verification
      └→ Ansible-CMDB Population
      ↓
Deployment Complete
```

## Deployment Scenarios (15 Options)

### Single Products
1. **Satellite Only** - Systems management & provisioning
   - Products: Satellite 6.18
   - Use cases: Standalone inventory management

2. **AAP Only** - Automation & orchestration
   - Products: AAP 2.6
   - Use cases: Standalone automation

3. **IdM Only** - Identity & access management
   - Products: IdM 3.0
   - Use cases: Standalone authentication

4. **OpenShift Only** - Container orchestration
   - Products: OpenShift 4.21+
   - Use cases: Container platform

### Dual Products
5. **Satellite + AAP** - Inventory + Automation
   - Products: Satellite 6.18, AAP 2.6
   - Integration: Satellite dynamic inventory in AAP

6. **Satellite + IdM** - Inventory + Identity
   - Products: Satellite 6.18, IdM 3.0
   - Integration: SSSD integration, unified authentication

7. **Satellite + OpenShift** - Inventory + Containers
   - Products: Satellite 6.18, OpenShift 4.21+
   - Integration: Image management, OS provisioning

8. **AAP + IdM** - Automation + Identity
   - Products: AAP 2.6, IdM 3.0
   - Integration: SSSD/Kerberos authentication

9. **AAP + OpenShift** - Automation + Containers
   - Products: AAP 2.6, OpenShift 4.21+
   - Integration: Container lifecycle automation

10. **IdM + OpenShift** - Identity + Containers
    - Products: IdM 3.0, OpenShift 4.21+
    - Integration: OpenShift OAuth via IdM

### Triple Products
11. **Satellite + AAP + IdM** - Complete management stack
    - Products: Satellite 6.18, AAP 2.6, IdM 3.0
    - Integrations: All dual integrations

12. **Satellite + AAP + OpenShift** - Inventory + Automation + Containers
    - Products: Satellite 6.18, AAP 2.6, OpenShift 4.21+
    - Integrations: All relevant integrations

13. **Satellite + IdM + OpenShift** - Inventory + Identity + Containers
    - Products: Satellite 6.18, IdM 3.0, OpenShift 4.21+
    - Integrations: All relevant integrations

14. **AAP + IdM + OpenShift** - Automation + Identity + Containers
    - Products: AAP 2.6, IdM 3.0, OpenShift 4.21+
    - Integrations: All relevant integrations

### Full Stack (DEFAULT)
15. **FULL STACK** - All products integrated
    - Products: Satellite 6.18, AAP 2.6, IdM 3.0, OpenShift 4.21+
    - Integration: Complete unified platform
    - **Use Case**: Production-grade infrastructure

## Platforms (7 Options)

1. **LibVirt** - Local KVM (Development/Testing)
2. **Bare Metal** - Physical servers with PXE
3. **AWS** - Amazon Web Services
4. **Azure** - Microsoft Azure
5. **GCP** - Google Cloud Platform
6. **VMware** - VMware vSphere
7. **Nutanix** - Nutanix HCI

## Directory Structure

```
RedHat_Management/
├── RHIS-Installer-Enhanced.sh         # Main installer entry point
├── RHIS-Installer.sh                  # Original installer (kept for compatibility)
├── playbooks/
│   ├── redhat_management-site.yml     # Main orchestration playbook
│   ├── init_installer_host.yml        # Initialize ansible developer node
│   ├── prepare_platform.yml           # Platform-specific preparation
│   ├── build_inventory.yml            # Dynamic inventory generation
│   ├── deploy_satellite.yml           # Satellite installation/config
│   ├── deploy_aap.yml                 # AAP installation/config
│   ├── deploy_idm.yml                 # IdM installation/config
│   ├── deploy_openshift.yml           # OpenShift installation/config
│   ├── configure_integrations.yml     # Post-deployment integrations
│   ├── setup_cmdb.yml                 # Ansible-CMDB setup
│   └── validation.yml                 # Deployment validation
├── roles/
│   ├── installer_host/                # Ansible developer node setup
│   ├── platform_prep/                 # Platform preparation
│   ├── inventory_generator/           # Inventory generation
│   ├── libvirt_vm_provisioner/       # LibVirt VM provisioning
│   ├── infrastructure_manager/        # Platform management (AWS, Azure, GCP, VMware, Nutanix)
│   ├── redhat_products/              # Product deployment roles
│   │   ├── satellite/
│   │   ├── aap/
│   │   ├── idm/
│   │   └── openshift/
│   ├── cmdb/                          # Ansible-CMDB role
│   ├── integration/                   # Integration roles
│   └── support/                       # Support utilities
├── group_vars/
│   ├── all.yml                        # Global variables
│   ├── satellite.yml                  # Satellite-specific
│   ├── aap.yml                        # AAP-specific
│   ├── idm.yml                        # IdM-specific
│   ├── openshift.yml                  # OpenShift-specific
│   ├── libvirt.yml                    # LibVirt-specific
│   ├── aws.yml                        # AWS-specific
│   ├── azure.yml                      # Azure-specific
│   ├── gcp.yml                        # GCP-specific
│   ├── vmware.yml                     # VMware-specific
│   └── nutanix.yml                    # Nutanix-specific
├── templates/
│   ├── ansible.cfg.j2                 # Ansible config template
│   ├── oemdrv/                        # OEMDRV kickstart templates
│   │   ├── satellite-ks.cfg.j2
│   │   ├── aap-ks.cfg.j2
│   │   ├── idm-ks.cfg.j2
│   │   └── openshift-ks.cfg.j2
│   └── repo-enable/                   # Repo enablement per scenario
│       ├── satellite-repos.sh.j2
│       ├── aap-repos.sh.j2
│       ├── idm-repos.sh.j2
│       └── openshift-repos.sh.j2
├── files/
│   ├── OEMDRV/                        # OEMDRV files per product
│   │   ├── satellite-ks.cfg
│   │   ├── aap-ks.cfg
│   │   ├── idm-ks.cfg
│   │   └── openshift-ks.cfg
│   ├── rhel-iso/                      # RHEL ISO location
│   ├── rpms/                          # Required RPMs not in repos
│   └── tftp/                          # TFTP boot files
├── inventory/
│   ├── hosts                          # Generated inventory
│   ├── generated/                     # Dynamic inventory output
│   └── examples/                      # Example inventory files
├── defaults/
│   └── global.yml                     # Global defaults
├── group_vars/
│   └── all.yml                        # Shared variables
├── host_vars/
│   └── [host-specific]                # Host-specific variables
├── docs/
│   ├── deployment/                    # Deployment documentation
│   ├── platforms/                     # Platform-specific guides
│   ├── products/                      # Product-specific guides
│   ├── operations/                    # Operations documentation
│   └── examples/                      # Example configurations
├── logs/
│   └── deployment_*.log               # Deployment logs
└── .ansible/conf/
    ├── env.yml                        # Vault-encrypted credentials
    └── deployment_config.yml          # Deployment configuration
```

## Tag Structure for Selective Execution

```
Scenario Tags:
  satellite, aap, idm, openshift           # Individual products
  multi-product                             # Multiple products
  full-stack                                # All products

Platform Tags:
  libvirt, baremetal                        # Local platforms
  aws, azure, gcp                           # Cloud platforms
  vmware, nutanix                           # Enterprise platforms
  cloud, enterprise, local                  # Platform categories

Phase Tags:
  init, prepare, provision                  # Infrastructure phases
  install, configure                        # Product phases
  integrate, validate                       # Integration phases

Component Tags:
  satellite, aap, idm, openshift           # Product-specific
  infrastructure, networking, storage       # Infrastructure-specific
  monitoring, backup, logging               # Cross-cutting concerns

## Example Tag Combinations

```bash
# Install Satellite on LibVirt
ansible-playbook redhat_management-site.yml \
  --tags "satellite,libvirt,rhel-9,install,configure"

# Full stack on AWS
ansible-playbook redhat_management-site.yml \
  --tags "full-stack,aws,rhel-9,install,configure,integrate"

# Only validate
ansible-playbook redhat_management-site.yml \
  --tags "validate"

# Multi-product (Sat+AAP+IdM) on Azure
ansible-playbook playbooks/redhat_management-site.yml \
  --tags "satellite,aap,idm,multi-product,azure,rhel-9"
```

## Credential Management

### Vault-Encrypted Storage
```
~/.ansible/conf/env.yml (vault-encrypted)
├── Red Hat CDN credentials
├── Offline token
├── Product admin passwords
├── Database credentials
├── Integration credentials
└── SSH keys for provisioning
```

### Never Hard-Coded
- No credentials in playbooks
- No credentials in group_vars
- No credentials in templates (unless vault-encrypted)
- Environment lookups with secure defaults
- Use `no_log: yes` for sensitive tasks

## Installation Methods

### 1. OEMDRV Kickstart
- Uses OEMDRV files (RHEL 9/10 kickstart format)
- Requires: RHEL ISO in files/rhel-iso/
- Supports: All platforms
- Automated unattended installation

### 2. TFTP/PXE Boot
- Sets up TFTP server on installer host
- Mounts RHEL ISO for PXE booting
- Supports: Bare Metal, KVM with network boot
- Network-based installation

## Repository Enablement

Per-scenario repo enablement scripts:
```
templates/repo-enable/
├── satellite-repos.sh.j2          # Satellite-specific repos
├── aap-repos.sh.j2                # AAP-specific repos
├── idm-repos.sh.j2                # IdM-specific repos
└── openshift-repos.sh.j2          # OpenShift-specific repos
```

Each script enables:
- Red Hat repos (via CDN or subscription)
- Product-specific repos
- Optional: Build repos, Tools repos
- Disabled by default: Optional, Testing repos

## Ansible-CMDB Integration

- Port: 8081 (non-conflicting with Satellite 80/443, AAP 443)
- Service: Systemd managed
- Data Source: Satellite inventory + ansible facts
- Dashboard: HTML fancy split view
- Updates: After each product integration

## Post-Deployment Checklist

- [ ] Credentials collected and secured
- [ ] Deployment scenario selected and confirmed
- [ ] Platform preparation completed
- [ ] Inventory generated and verified
- [ ] Satellite 6.18 installed and configured
- [ ] AAP 2.6 installed and configured
- [ ] IdM 3.0 installed and configured
- [ ] OpenShift 4.21+ installed and configured
- [ ] All integrations configured
- [ ] Ansible-CMDB populated with inventory
- [ ] Health checks passed
- [ ] Integration tests passed
- [ ] Deployment validated and verified

