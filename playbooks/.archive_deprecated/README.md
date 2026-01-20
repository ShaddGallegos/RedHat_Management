---
# README: Playbooks Architecture & Reorganization
# 
# This directory contains consolidated ansible_dev_node_orchestration playbooks.
# All utility tasks have been moved to roles for better reusability and maintainability.

## Active Playbooks (5 total)

### 1. site.yml (MAIN ENTRY POINT)
   - Unified ansible_dev_node_orchestration playbook
   - Coordinates all setup and deployment phases
   - Includes: Setup → Inventory Generation → Infrastructure Prep → Component Deployment
   - Call this to start interactive deployment

### 2. deploy_components.yml (COMPONENT ORCHESTRATION)
   - Orchestrates deployment of all enterprise components
   - Handles component sequencing and dependencies
   - Manages integration_generic between components
   - Deployed by: site.yml

### 3. load_vaulted_env.yml (SECRETS MANAGEMENT)
   - Pre-deployment task to load vault-encrypted secrets
   - Makes secrets available as facts
   - Called by: site.yml (pre_tasks)

### 4. phase_6_3_cleanup.yml (ARCHIVE & CLEANUP)
   - Legacy file from Phase 6.3
   - Archives old files and organizes documentation
   - Can be kept for reference or archived

### 5. phase_6_4_validation.yml (VALIDATION)
   - Legacy testing playbook from Phase 6.4
   - Validates project structure and generates reports
   - Can be kept for reference or archived

## Archived Playbooks (36 total in _archived_playbooks/)

These playbooks have been consolidated into roles:
- setup_framework.yml → roles/ansible_dev_node_deployment_setup
- generate_inventory.yml → roles/ansible_dev_node_inventory_generator
- deploy_libvirt.yml → roles/platform_infrastructure_prep
- [30+ other utility playbooks] → Various roles

## New Role-Based Architecture

### Orchestration Roles
1. **ansible_dev_node_deployment_setup** - Interactive configuration (formerly setup_framework.yml)
2. **ansible_dev_node_inventory_generator** - Inventory generation (formerly generate_inventory.yml)
3. **platform_infrastructure_prep** - Libvirt setup (formerly deploy_libvirt.yml)
4. **load_vaulted_env** - Secrets management (from load_vaulted_env.yml)

### Component Roles
1. **scenario_ansible_cmdb_setup** - Infrastructure visibility
2. **satellite_6_18_deployment** - Content management
3. **scenario_aap_setup** - Automation platform
4. **idm_integration** - Identity management
5. **scenario_openshift_4_21_deployment** - Container platform

## Quick Start

```bash
# Run complete interactive deployment
ansible-playbook site.yml

# Run component deployment only (after setup)
ansible-playbook deploy_components.yml

# Load vault secrets
ansible-playbook load_vaulted_env.yml
```

## Recommendation for Further Cleanup

To fully consolidate:
1. Archive phase_6_3_cleanup.yml → archive/
2. Archive phase_6_4_validation.yml → archive/
3. Keep deploy_components.yml but simplify by moving more logic to roles
4. Make site.yml the single entry point for all deployments

This reduces playbook directory complexity from 41 to 2 files.
