# Role: cmdb

## Description

The `cmdb` role manages the Configuration Management Database (CMDB), tracking deployed infrastructure, configurations, and changes.

**Key Responsibility**: Manage and track infrastructure configuration database.

## When to Use

- Tracking deployed infrastructure
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
    - role: cmdb
      vars:
        cmdb_enabled: true
```

## Support & Documentation

See orchestration_master README for integration.

## Author

Red Hat Management Team

## License

Apache-2.0
