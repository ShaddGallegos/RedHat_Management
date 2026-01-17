# Product Lifecycle Roles

Generic orchestration roles for standardized product lifecycle operations.

## Overview

These roles provide a framework for consistent product lifecycle management across all products (AAP, Satellite, IdM, OpenShift).

## Roles

### install/
Orchestrator role for product installation.

**Variables:**
```yaml
product_name: "aap"  # Product to install
product_roles: []    # Roles that perform actual installation
skip_validation: false
```

**Usage:**
```yaml
- name: Install AAP
  hosts: aap
  roles:
    - aap_2_6_setup              # Product-specific role
    - product_lifecycle/install  # Lifecycle orchestrator
```

### backup/
Orchestrator role for product backup.

**Variables:**
```yaml
product_name: "aap"
backup_type: "full"  # database, configuration, full
backup_dir: "/var/backups"
product_backup_paths: []
```

**Usage:**
```yaml
- name: Backup AAP
  hosts: aap
  roles:
    - role: product_lifecycle/backup
      vars:
        product_name: aap
        backup_dir: /var/backups/aap
```

### test/
Orchestrator role for product testing.

**Variables:**
```yaml
product_name: "aap"
test_types:
  - connectivity
  - services
  - api
product_services: []
product_api_endpoints: []
```

**Usage:**
```yaml
- name: Test AAP
  hosts: aap
  roles:
    - role: product_lifecycle/test
      vars:
        product_name: aap
        product_services:
          - automation-controller
          - automation-hub
```

### integrate/
Orchestrator role for product integration.

**Variables:**
```yaml
product_name: "aap"
integration_targets: []  # [satellite, idm, insights]
```

**Usage:**
```yaml
- name: Integrate AAP with Satellite
  hosts: aap
  roles:
    - role: product_lifecycle/integrate
      vars:
        product_name: aap
        integration_targets:
          - satellite
          - idm
```

## Collections Used

- `ansible.builtin.*` - Core modules
- `ansible.posix.*` - POSIX modules
- `community.general.*` - Community modules

## Tags

All tasks tagged with:
- `install`, `backup`, `test`, `integrate`
- Product name: `aap`, `satellite`, `idm`, etc.
- Functional area: `validate`, `configuration`, etc.

## See Also

- [Product Roles](../redhat_products/README.md)
- [Support Roles](../support/README.md)
- [Common Tasks](../common_tasks/README.md)
