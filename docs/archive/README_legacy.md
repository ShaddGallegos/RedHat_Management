# Scripts Directory - Fully Organized & Cleaned

This directory contains all helper scripts for the Red Hat Infrastructure Setup (RHIS) project.

**Status:**  Fully organized by type, all empty directories removed, no unnecessary files.

---

## Directory Structure

```
scripts/
 🚀 setup/              [6 scripts]   Initialization & setup
 ️  configuration/      [3 scripts]   Configuration management
 🏗️  platform_infrastructure_core/     [2 scripts]   VM platform_provisioning
 🔧 maintenance/        [3 scripts]   System updates
  validation/         [1 script]    Testing & validation
 🛠️  utilities/          [5 scripts]   Helper utilities
 📚 lib/
    shell/            [1 file]      Reusable shell functions
    python/           [4 files]     Python modules & utilities
 📋 config/             [6 files]    Requirements & environment
 💾 data/               [2 files]    Static data
 📚 archive/                        Legacy directories (reference only)
 INDEX.md                          Complete script index
 README.md                         This file
 REORGANIZATION.md                 Best practices guide
```

---

## Scripts by Category

### 🚀 Setup (6 scripts)
Initialization and installation.

- `initialization.sh` - Initialize environment
- `run_setup.sh` - Main setup orchestrator
- `run_all_setup.sh` - Complete automation
- `clone_compliance_roles.sh` - Clone compliance roles
- `load_redhat_credentials.sh` - Load RedHat credentials
- `export_rhis_container.sh` - Export RHIS container

### ️  Configuration (3 scripts)
Configuration generation and management.

- `configure_aap_inventory.py` - Generate AAP inventory
- `generate_ansible_cfg.py` - Generate ansible.cfg
- `update_ansible_token.py` - Update Ansible tokens

### 🏗️  Infrastructure (2 scripts)
VM platform_provisioning and platform_infrastructure_core management.

- `create_libvirt_vm_from_iso.sh` - Create VMs from ISO
- `libvirt_vm_helper.sh` - Libvirt VM utilities

### 🔧 Maintenance (3 scripts)
System updates and maintenance.

- `update.sh` - Update system packages
- `update_containers.sh` - Update container images
- `run_container.sh` - Container execution

###  Validation (1 script)
Testing and validation.

- `validate-reorganization.sh` - Validate structure

### 🛠️  Utilities (5 scripts)
Helper and fixup scripts.

- `fixup_satellite_more.py` - Fix Satellite configuration
- `fixup_satellite_role.py` - Fix Satellite roles
- `fix_pipes_and_permissions.py` - Fix pipes & permissions
- `remove_blank_lines_configure.py` - Clean configuration files
- `convert_to_fqcn.py` - Convert to FQCN

---

## Reusable Libraries

### 📚 lib/shell/ - Shell Functions
**common.sh** - 25+ reusable functions for logging, validation, utilities

### 📚 lib/python/ - Python Modules (4 files)
**common.py** - 30+ utility functions, classes for logging, file ops, commands

**Utility Modules:**
- `convert_rhis_templates.py` - Template conversion
- `kickstart_http_server.py` - HTTP server for kickstart
- `platform_libvirt_vm_provisioner.py` - Libvirt VM platform_provisioning

---

## Configuration & Data Files

### 📋 config/ (6 files)
- requirements.txt, requirements.yml, requirements_hub.yml
- env.local.generated.yml, test-env.yml, render_env.yml

### 💾 data/ (2 files)
- bindep.txt - Binary dependencies
- system_prompts.yml - System prompt templates

---

## Quick Start

```bash
./scripts/setup/run_all_setup.sh
./scripts/configuration/generate_ansible_cfg.py
./scripts/platform_infrastructure_core/create_libvirt_vm_from_iso.sh rhel.iso vm-name
./scripts/maintenance/update.sh
./scripts/validation/validate-reorganization.sh
```

---

**Last Updated:** January 16, 2026  
**Status:**  Fully organized and cleaned - no empty directories or unnecessary files
