# rhis_inventory_integration

Provide RHIS inventory configuration reference and custom tasks.

## Purpose

This role:
- Loads RHIS inventory configuration templates
- Executes custom external tasks
- Provides reference to all available inventory templates
- Integrates example.ca organization inventory structure

## Templates Available

### Provisioning Templates (templates/rhis/provisioning/)
- 20+ Satellite provisioning templates
- PXE boot templates
- Partition table configurations
- Job templates for host provisioning

### Configuration Templates (templates/rhis/configs/)
- Chrony configuration
- PostgreSQL tuning
- Keycloak configuration
- IPA/FreeIPA configuration
- Foreman configuration
- /etc/hosts template

### Inventory Templates (templates/rhis/inventory/)
- Enterprise topology (container)
- Enterprise topology (RPM)
- Growth topology (container)
- Growth topology (RPM)
- Standalone topology
- Standalone Hub topology
- Ansible inventory generator
- Custom RPM inventory

### Execution Environment (templates/rhis/execution-env/)
- Execution environment YAML template

## Supporting Files (files/rhis/)

- OpenSCAP content (RHEL 7, 8, 9)
- Tailoring files for security compliance
- Custom RPM examples
- RHSM configuration templates
- Supporting scripts
- Clone compliance roles script

## Example Usage

```yaml
- hosts: localhost
  roles:
    - role: rhis_inventory_integration
```

## Tags

- `rhis_custom_tasks` - Execute custom external tasks
- `always` - Display inventory information

## Notes

- All templates are examples from example.ca organization
- Templates reference hardcoded values (example.ca) - customize as needed
- Custom tasks in tasks/ directory can be organization-specific
- Template and file references available via role defaults

## Migration Source

Originally from `contrib/upstreams/rhis-builder-inventory/example.ca/`
