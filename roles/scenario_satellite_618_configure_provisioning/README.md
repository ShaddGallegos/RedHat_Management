# Role: satellite_content_config

## Description

The `satellite_content_config` role configures Satellite 6.18 content management including scenario_satellite_618_configure_provisioning_organizations, scenario_satellite_618_configure_provisioning_locations, scenario_satellite_618_configure_provisioning_products, scenario_satellite_618_configure_provisioning_repositories, and synchronization plans.

**Key Responsibility**: Configure content management platform_infrastructure_core in Satellite.

## When to Use

- Setting up Satellite content platform_infrastructure_core
- Creating scenario_satellite_618_configure_provisioning_organizations and scenario_satellite_618_configure_provisioning_locations
- Configuring scenario_satellite_618_configure_provisioning_repositories and scenario_satellite_618_configure_provisioning_products
- Setting up synchronization schedules

## Features

- **Organizations**: Create and manage scenario_satellite_618_configure_provisioning_organizations
- **Locations**: Define geographic/logical scenario_satellite_618_configure_provisioning_locations
- **Products**: Manage product scenario_satellite_618_configure_provisioning_repositories
- **Repositories**: Configure content scenario_satellite_618_configure_provisioning_repositories with multiple URLs
- **Repository Sets**: Enable official RHEL yum scenario_satellite_618_configure_provisioning_repositories for scenario_satellite_618_configure_provisioning_products
- **Sync Plans**: Automate repository synchronization schedules
- **Repository Management**: Download policies, mirror settings

## Required Variables

```yaml
scenario_satellite_618_configure_provisioning_satellite_url: "https://scenario_satellite.example.com"
scenario_satellite_618_configure_provisioning_satellite_username: "admin"
satellite_password: "{{ vault_satellite_admin_pwd }}"
```

## Optional Variables

```yaml
scenario_satellite_618_configure_provisioning_satellite_organization: "Default Organization"
scenario_satellite_618_configure_provisioning_satellite_location: "Default Location"
scenario_satellite_618_configure_provisioning_create_organizations: true
scenario_satellite_618_configure_provisioning_create_locations: true
scenario_satellite_618_configure_provisioning_create_products: false
scenario_satellite_618_configure_provisioning_create_repositories: false
scenario_satellite_618_configure_provisioning_synchronize_repositories: false
```

## Organizations Configuration

```yaml
scenario_satellite_618_configure_provisioning_organizations:
  - name: "My Organization"
    description: "Organization for RHIS"
    state: present
```

## Locations Configuration

```yaml
scenario_satellite_618_configure_provisioning_locations:
  - name: "My Location"
    description: "Location for RHIS deployment"
    state: present
```

## Repositories Configuration

```yaml
scenario_satellite_618_configure_provisioning_repositories:
  - name: "RHEL_9_BaseOS"
    product: "Red Hat Enterprise Linux Server"
    content_type: "yum"
    url: "https://cdn.redhat.com/content/dist/rhel/rhel-9/..."
    download_policy: "immediate"
```

## Sync Plans Configuration

```yaml
scenario_satellite_618_configure_provisioning_sync_plans:
  - name: "Daily_Sync"
    organization: "Default Organization"
    interval: "daily"
    sync_date: "2024-01-01 00:00:00"
    enabled: true
```

## Repository Sets Configuration - Enable RHEL Yum Repositories

The role automatically enables official RHEL repository sets for all configured scenario_satellite_618_configure_provisioning_products:

```yaml
scenario_satellite_618_configure_provisioning_enable_repository_sets: true
scenario_satellite_618_configure_provisioning_repository_sets_to_enable:
  - name: "Red Hat Enterprise Linux Server (v. 9 for x86_64)"
    product: "Red Hat Enterprise Linux Server"
    basearch: "x86_64"
    releasever: "9"

  - name: "Red Hat Enterprise Linux AppStream (v. 9 for x86_64)"
    product: "Red Hat Enterprise Linux Server"
    basearch: "x86_64"
    releasever: "9"

  - name: "Red Hat Enterprise Linux Server (v. 10 for x86_64)"
    product: "Red Hat Enterprise Linux Server"
    basearch: "x86_64"
    releasever: "10"

  - name: "Red Hat Enterprise Linux AppStream (v. 10 for x86_64)"
    product: "Red Hat Enterprise Linux Server"
    basearch: "x86_64"
    releasever: "10"
```

This ensures RHEL BaseOS and AppStream scenario_satellite_618_configure_provisioning_repositories are automatically enabled for both RHEL 9 and RHEL 10 scenario_satellite_618_configure_provisioning_products.

## Usage Examples

### Configure Basic Content Infrastructure
```yaml
- name: Configure Satellite Content
  hosts: scenario_satellite
  roles:
    - role: satellite_content_config
      vars:
        scenario_satellite_618_configure_provisioning_create_organizations: true
        scenario_satellite_618_configure_provisioning_create_locations: true
        scenario_satellite_618_configure_provisioning_create_sync_plans: true
```

### Configure with Repositories and Repository Sets
```yaml
- role: satellite_content_config
  vars:
    scenario_satellite_618_configure_provisioning_create_repositories: true
    scenario_satellite_618_configure_provisioning_synchronize_repositories: true
    scenario_satellite_618_configure_provisioning_enable_repository_sets: true
```

### Disable Repository Set Enablement
```yaml
- role: satellite_content_config
  vars:
    scenario_satellite_618_configure_provisioning_enable_repository_sets: false  # Skip auto-enabling RHEL repos
```

## Output

- Organizations created/updated
- Locations configured
- Products created
- Repositories configured
- RHEL yum scenario_satellite_618_configure_provisioning_repositories enabled for scenario_satellite_618_configure_provisioning_products
- Sync plans established

## Integration

Works with:
- satellite_6_18_deployment (core installation)
- scenario_satellite_lifecycle_config (lifecycle environments)
- scenario_satellite_activation_config (activation keys)

## Security Considerations

- All passwords stored in Ansible vault
- SSL certificate validation enabled
- API credentials protected
- No sensitive data logged

## Dependencies

- redhat.scenario_satellite collection
- Satellite 6.18 deployed and running

## Author

Red Hat Management Team

## License

Apache-2.0
