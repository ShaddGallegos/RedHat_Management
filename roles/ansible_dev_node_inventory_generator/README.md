# Role: ansible_dev_node_inventory_generator

## Description

The `ansible_dev_node_inventory_generator` role dynamically generates Ansible inventory based on deployment configuration, platform selection, and product requirements.

**Key Responsibility**: Generate deployment inventory dynamically.

## When to Use

- Creating deployment inventory
- Multi-environment deployments
- Dynamic host discovery
- Inventory templating

## Features

- **Dynamic Generation**: Generate inventory from variables
- **Multi-Environment**: Support multiple environments
- **Host Grouping**: Automatic group creation
- **Variable Population**: Populate host variables
- **Format Support**: Multiple inventory formats

## Usage Examples

```yaml
- name: Generate Inventory
  hosts: localhost
  roles:
    - role: ansible_dev_node_inventory_generator
      vars:
        deployment_scenario: "satellite_aap"
```

## Support & Documentation

See ansible_dev_node_orchestration_master README for integration_generic.

## Author

Red Hat Management Team

## License

Apache-2.0
