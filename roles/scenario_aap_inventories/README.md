# Role: scenario_aap_inventories

## Description

The `scenario_aap_inventories` role configures inventories in Ansible Automation Platform (AAP). It manages static inventories, dynamic inventory sources, and inventory synchronization.

**Key Responsibility**: Configure and manage AAP inventories.

## When to Use

- Setting up AAP inventories for RHIS
- Creating static and dynamic inventories
- Configuring inventory sources
- Inventory synchronization management

## Features

- **Static Inventories**: Manual host management
- **Dynamic Inventories**: Auto-populated from sources
- **Inventory Sources**: Satellite, AWS, project sources
- **Variables**: Inventory-level variable configuration
- **Sync**: Automatic inventory synchronization

## Required Variables

```yaml
aap_url: "https://aap.example.com"
aap_username: "admin"
aap_password: "{{ vault_aap_admin_pwd }}"
```

## Optional Variables

```yaml
aap_inventories_organization: "Default"
create_static_inventories: true
create_dynamic_inventories: true
create_inventory_sources: true
aap_inventories_test_imports: true
```

## Inventory Types

### Static Inventories
Manual host/group definitions
```yaml
static_inventories:
  - name: "RHIS_Infrastructure"
    description: "RHIS hosts"
    variables:
      ansible_user: "ansible"
```

### Dynamic Inventories
Auto-populated from external sources
```yaml
dynamic_inventories:
  - name: "Satellite_Sync"
    source: "scenario_satellite"
    source_vars:
      satellite_host: "scenario_satellite.example.com"
```

### Inventory Sources
Define sync sources
```yaml
inventory_sources:
  - name: "RHIS_Project_Sync"
    inventory: "RHIS_Infrastructure"
    source: "project"
    source_path: "inventory/hosts"
```

## Usage Examples

### Configure All Inventories
```yaml
- name: Configure AAP Inventories
  hosts: localhost
  roles:
    - role: scenario_aap_inventories
      vars:
        create_static_inventories: true
        create_dynamic_inventories: true
        create_inventory_sources: true
```

## Dependencies

None (AAP must be running)

## Author

Red Hat Management Team

## License

Apache-2.0
