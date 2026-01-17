# Red Hat Management Enterprise Automation Framework

**Documentation Index**

## Core Documentation

- [00_PROJECT_README.md](00_PROJECT_README.md) - Project overview and getting started
- [01_DELIVERABLES_INDEX.md](01_DELIVERABLES_INDEX.md) - Complete deliverables listing
- [02_ROLE_STRUCTURE.md](02_ROLE_STRUCTURE.md) - Ansible role architecture
- [03_ROLES_INDEX.md](03_ROLES_INDEX.md) - Role reference guide
- [04_PHASE6_OVERVIEW.md](04_PHASE6_OVERVIEW.md) - Phase 6 overview

## Phase Documentation

- [PHASE6.md](PHASE6.md) - Complete Phase 6 documentation

## Component Guides

See subdirectories for component-specific documentation:
- `satellite/` - Satellite 6.18 guides
- `aap/` - AAP 2.6 guides
- `controller/` - Controller guides
- `eda/` - Event-Driven Automation
- `idm/` - Identity Management
- `openshift/` - OpenShift 4.21
- `openshift-virtualization/` - OpenShift Virtualization
- `libvirt/` - Libvirt platform guide
- `aws/` - AWS deployment guide
- `azure/` - Azure deployment guide
- `gcp/` - GCP deployment guide
- `vmware/` - VMware deployment guide
- `nutanix/` - Nutanix deployment guide
- `automation-hub/` - Automation Hub
- `insights/` - Red Hat Insights
- `receptor/` - Receptor networking
- `servicenow/` - ServiceNow integration
- `terraform/` - Terraform integration
- `snmp/` - SNMP monitoring
- `yang/` - YANG models

## Quick Start

```bash
# Interactive setup
cd /run/media/sgallego/SD_Card/GIT/RedHat_Management
ansible-playbook site.yml

# Deploy components
ansible-playbook playbooks/deploy_components.yml
```

## Support

For detailed component information, see component-specific documentation in subdirectories.
