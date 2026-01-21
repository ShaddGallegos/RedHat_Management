# Role: scenario_ansible_cmdb_core

## Description

The `scenario_ansible_cmdb_core` role manages the Configuration Management Database (CMDB), tracking deployed platform_infrastructure_core, configurations, and changes.

**Key Responsibility**: Manage and track platform_infrastructure_core configuration database.

## When to Use

- Tracking deployed platform_infrastructure_core
- Configuration change management
- Asset inventory
- Compliance tracking

## Features

- **Configuration Tracking**: Track all configurations
- **Change History**: Maintain change history
- **Asset Inventory**: Track assets
- **Compliance**: Track compliance status
- **Reporting**: Generate reports

## Usage Examples

```yaml
- name: Setup CMDB
  hosts: localhost
  roles:
    - role: scenario_ansible_cmdb_core
      vars:
        scenario_ansible_cmdb_core_cmdb_enabled: true
```

## Support & Documentation

See ansible_dev_node_orchestration_master README for integration_generic.

## Author

Red Hat Management Team

## License

Apache-2.0
