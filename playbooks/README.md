# RHIS Playbooks Directory

This directory contains the main ansible_dev_node_orchestration playbooks for Red Hat Infrastructure Standard deployments.

## Playbooks

### site.yml (MAIN ENTRY POINT)
Primary ansible_dev_node_orchestration playbook for RHIS deployments.

**Features:**
- Interactive scenario and platform selection
- Support for all 15 deployment scenarios
- Support for all 7 cloud platforms
- 7-phase ansible_dev_node_orchestration
- Comprehensive logging and reporting

**Usage:**
```bash
# Interactive deployment
ansible-playbook site.yml

# Non-interactive deployment
ansible-playbook site.yml \
  -e deployment_scenario=satellite_aap \
  -e deployment_platform=libvirt \
  -e deployment_os=rhel-9

# Execute specific phases
ansible-playbook site.yml -t phase1,phase2,phase3
```

### ansible_dev_node_orchestration.yml
Alternative entry point for direct ansible_dev_node_orchestration (non-interactive).

**Usage:**
```bash
ansible-playbook ansible_dev_node_orchestration.yml \
  -e deployment_scenario=full_stack \
  -e deployment_platform=aws
```

## Architecture

All ansible_dev_node_orchestration logic has been consolidated into roles for better maintainability and reusability:

- **ansible_dev_node_orchestration_master** - Main ansible_dev_node_orchestration role (7-phase workflow)
- **ansible_dev_node_configuration_manager** - Credential and configuration management
- **ansible_dev_node_redhat_products/*** - Product-specific deployment roles
- **platform_infrastructure_manager** - Platform platform_provisioning and networking
- **integration_generic** - Product integration_generic tasks
- **scenario_ansible_cmdb_core** - Ansible-CMDB setup and management
- **ansible_dev_node_support** - Health checks and validation

## Deployment Scenarios (15 Total)

| Scenario | Products | Use Case |
|----------|----------|----------|
| satellite_only | Satellite | Systems management |
| aap_only | AAP | Automation platform |
| idm_only | IdM | Identity management |
| openshift_only | OpenShift | Container platform |
| satellite_aap | Sat + AAP | Inventory + Automation |
| satellite_idm | Sat + IdM | Inventory + Identity |
| satellite_openshift | Sat + OCP | Inventory + Containers |
| aap_idm | AAP + IdM | Automation + Identity |
| aap_openshift | AAP + OCP | Automation + Containers |
| idm_openshift | IdM + OCP | Identity + Containers |
| satellite_aap_idm | Sat + AAP + IdM | Management Stack |
| satellite_aap_openshift | Sat + AAP + OCP | Hybrid Stack |
| satellite_idm_openshift | Sat + IdM + OCP | Identity Stack |
| aap_idm_openshift | AAP + IdM + OCP | Automation Stack |
| full_stack | All 4 products | Complete integration_generic |

## Supported Platforms (7 Total)

- LibVirt (KVM) - Development/Testing
- Bare Metal - Enterprise
- AWS - Cloud
- Azure - Cloud
- GCP - Cloud
- VMware - Enterprise
- Nutanix - Enterprise

## 7-Phase Orchestration

1. **Phase 1** - Ansible Developer Node Initialization
2. **Phase 2** - Platform Infrastructure Preparation
3. **Phase 3** - Dynamic Inventory Generation
4. **Phase 4** - Product Deployment (Satellite, AAP, IdM, OpenShift)
5. **Phase 5** - Product Integration Configuration
6. **Phase 6** - Ansible-CMDB Setup
7. **Phase 7** - Deployment Validation and Reporting

## Configuration

Deployment configuration is stored at:
```
~/.ansible/conf/deployment_config.yml
```

Vault-encrypted credentials are stored at:
```
~/.ansible/conf/env.yml
```

## Logging

Deployment logs are written to:
```
logs/deployment_TIMESTAMP.log
logs/orchestration_TIMESTAMP.log
```

## Tags

All playbooks ansible_dev_node_support tag-based execution:

```bash
# Phase-based execution
ansible-playbook site.yml -t phase1
ansible-playbook site.yml -t phase1,phase2,phase3

# Product-based execution
ansible-playbook site.yml -t scenario_satellite
ansible-playbook site.yml -t aap,idm

# Operation-based execution
ansible-playbook site.yml -t provision
ansible-playbook site.yml -t install
ansible-playbook site.yml -t configure
ansible-playbook site.yml -t integrate
ansible-playbook site.yml -t validate
```

## Previous Versions

Legacy playbooks have been archived in `.archive_deprecated/`:
- deploy_components-site.yml
- redhat_management-site.yml
- prompts_and_config.yml
- scenario_configs.yml
- Product-specific playbooks (products/*)

These are maintained for reference but should not be used. All logic has been consolidated into the role-based architecture.

## Documentation

- Architecture: `docs/deployment/RHIS_DEPLOYMENT_ARCHITECTURE.md`
- Quick Start: `docs/deployment/QUICK_START.md`
- Best Practices: `docs/examples/PLAYBOOK_ORGANIZATION_BEST_PRACTICES.md`
- Jinja2 Variables: `docs/examples/JINJA2_VARIABLES_REFERENCE.yml`

## Support

For troubleshooting and ansible_dev_node_support, see:
- `docs/troubleshooting/` - Troubleshooting guides
- `roles/*/README.md` - Role-specific documentation
- `logs/` - Deployment logs
