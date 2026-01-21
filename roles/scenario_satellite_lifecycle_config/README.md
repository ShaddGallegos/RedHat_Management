# Role: scenario_satellite_lifecycle_config

## Description

The `scenario_satellite_lifecycle_config` role configures Satellite 6.18 content lifecycle management including lifecycle environments, content views, filters, and promotion workflows.

**Key Responsibility**: Configure lifecycle environments and content views in Satellite.

## When to Use

- Setting up content lifecycle management
- Creating content views with repositories
- Configuring promotion paths
- Managing content filtering and versioning

## Features

- **Lifecycle Environments**: Development, Staging, Production paths
- **Content Views**: Single and composite content views
- **Content Filters**: Errata, package, and module filtering
- **Publishing**: Publish content views to versions
- **Promotion**: Promote versions through lifecycle
- **Composite Views**: Combine multiple content views

## Required Variables

```yaml
scenario_satellite_lifecycle_config_satellite_url: "https://scenario_satellite.example.com"
scenario_satellite_lifecycle_config_satellite_username: "admin"
satellite_password: "{{ vault_satellite_admin_pwd }}"
```

## Lifecycle Environments

```yaml
scenario_satellite_lifecycle_config_lifecycle_environments:
  - name: "Development"
    prior: "Library"
    description: "Development environment"
  - name: "Staging"
    prior: "Development"
    description: "Staging environment"
  - name: "Production"
    prior: "Staging"
    description: "Production environment"
```

## Content Views

```yaml
scenario_satellite_lifecycle_config_content_views:
  - name: "RHIS_BaseOS"
    description: "Base OS content"
    repositories:
      - "RHEL 9 BaseOS"
      - "RHEL 9 AppStream"
```

## Content View Filters

```yaml
scenario_satellite_lifecycle_config_content_view_filters:
  - name: "Security_Errata"
    content_view: "RHIS_BaseOS"
    filter_type: "erratum"
    inclusion: true
```

## Usage Examples

### Configure Lifecycle Environments
```yaml
- name: Configure Satellite Lifecycle
  hosts: scenario_satellite
  roles:
    - role: scenario_satellite_lifecycle_config
      vars:
        scenario_satellite_lifecycle_config_create_lifecycle_environments: true
        scenario_satellite_lifecycle_config_create_content_views: true
```

### Configure and Publish
```yaml
- role: scenario_satellite_lifecycle_config
  vars:
    scenario_satellite_lifecycle_config_create_content_views: true
    scenario_satellite_lifecycle_config_publish_content_views: true
    scenario_satellite_lifecycle_config_promote_content_views: true
```

## Output

- Lifecycle environments created
- Content views configured
- Filters applied
- Composite views created
- Promotion paths established

## Integration

Works with:
- satellite_content_config (repositories setup)
- scenario_satellite_activation_config (activation keys)

## Security Considerations

- All passwords stored in vault
- SSL certificate validation
- API credentials protected
- No sensitive data logged

## Dependencies

- redhat.scenario_satellite collection
- Satellite 6.18 with initialized organization

## Author

Red Hat Management Team

## License

Apache-2.0
