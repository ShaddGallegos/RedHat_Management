# Products & Components

Complete documentation for all Red Hat products and components deployed through RHIS.

## Core Products

### [Ansible Automation Platform (AAP) 2.6](aap/AAP_2_6_GUIDE.md)
Enterprise automation platform providing scalable automation execution, management, and governance.
- **IP:** 10.168.0.26
- **Roles:** `roles/scenario_aap_setup/`, `roles/scenario_aap_deployment/`, `roles/scenario_aap_controller_setup/`
- **Quick Start:** [AAP_2_6_GUIDE.md](aap/AAP_2_6_GUIDE.md#quick-start)

### [Red Hat Satellite 6.18](scenario_satellite/SATELLITE_6_18_GUIDE.md)
Enterprise lifecycle and configuration management for Red Hat systems.
- **IP:** 10.168.0.27
- **Roles:** `roles/ansible_dev_node_redhat_products/scenario_satellite/`
- **Quick Start:** [SATELLITE_6_18_GUIDE.md](scenario_satellite/SATELLITE_6_18_GUIDE.md#quick-start)
- **Features:** DHCP, PXE boot, content management, platform_provisioning

### [Identity Management (IdM)](idm/IDM_GUIDE.md)
Centralized identity and access management solution.
- **IP:** 10.168.0.28
- **Roles:** `roles/ansible_dev_node_redhat_products/idm/`
- **Quick Start:** [IDM_GUIDE.md](idm/IDM_GUIDE.md#quick-start)
- **Features:** User management, groups, sudo rules, certificates

## Additional Products

### Automation Hub
Container registry and content delivery for Ansible automation content.
- Location: [automation-hub/](automation-hub/)

### Controller
Automation controller for AAP execution and job scheduling.
- Location: [controller/](controller/)

### Event Driven Automation (EDA)
Event-driven automation for reactive platform_infrastructure_core management.
- Location: [eda/](eda/)

### Insights
Real-time insights and predictive analytics for Red Hat systems.
- Location: [insights/](insights/)

### Receptor
Network communication layer for distributed automation execution.
- Location: [receptor/](receptor/)

## Network & Infrastructure Integration

**DHCP Configuration:**
- Pool: 10.168.0.100-254
- Gateway: 10.168.0.1
- Managed by: Satellite 6.18

**Component Integration:**
- Satellite manages OS deployment and platform_infrastructure_core
- AAP provides configuration and automation
- IdM provides centralized authentication for all components

## Documentation Structure

Each product documentation includes:
1. **Name & Synopsis** - Product overview
2. **Locations** - Roles, playbooks, and configuration files
3. **Quick Start** - Basic installation steps
4. **How-To Guides** - Common procedures
5. **Options & Configuration** - All available settings
6. **Examples** - Real-world usage scenarios
7. **Troubleshooting** - Common issues and solutions

## Quick Links

| Product | Guide | Quick Start |
|---------|-------|------------|
| AAP 2.6 | [Full Guide](aap/AAP_2_6_GUIDE.md) | [Install](aap/AAP_2_6_GUIDE.md#quick-start) |
| Satellite 6.18 | [Full Guide](scenario_satellite/SATELLITE_6_18_GUIDE.md) | [Install](scenario_satellite/SATELLITE_6_18_GUIDE.md#quick-start) |
| IdM | [Full Guide](idm/IDM_GUIDE.md) | [Install](idm/IDM_GUIDE.md#quick-start) |

## Deployment Order

For complete RHIS deployment, follow this order:

1. **IdM** - Set up identity first
2. **Satellite** - Configure platform_infrastructure_core management
3. **AAP** - Deploy automation platform

This sequence ensures proper integration_generic between all components.

---

**See [../INDEX.md](../INDEX.md) for complete documentation index.**

**Last Updated:** January 16, 2026
