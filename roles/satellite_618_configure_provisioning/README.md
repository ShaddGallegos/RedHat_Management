# Role: satellite_content_config

## Description

The `satellite_content_config` role configures Satellite 6.18 content management including organizations, locations, products, repositories, and synchronization plans.

**Key Responsibility**: Configure content management infrastructure in Satellite.

## When to Use

- Setting up Satellite content infrastructure
- Creating organizations and locations
- Configuring repositories and products
- Setting up synchronization schedules

## Features

- **Organizations**: Create and manage organizations
- **Locations**: Define geographic/logical locations
- **Products**: Manage product repositories
- **Repositories**: Configure content repositories with multiple URLs
- **Repository Sets**: Enable official RHEL yum repositories for products
- **Sync Plans**: Automate repository synchronization schedules
- **Repository Management**: Download policies, mirror settings

## Required Variables

```yaml
satellite_url: "https://satellite.example.com"
satellite_username: "admin"
satellite_password: "{{ vault_satellite_admin_pwd }}"
```

## Optional Variables

```yaml
satellite_organization: "Default Organization"
satellite_location: "Default Location"
create_organizations: true
create_locations: true
create_products: false
create_repositories: false
synchronize_repositories: false
```

## Organizations Configuration

```yaml
organizations:
  - name: "My Organization"
    description: "Organization for RHIS"
    state: present
```

## Locations Configuration

```yaml
locations:
  - name: "My Location"
    description: "Location for RHIS deployment"
    state: present
```

## Repositories Configuration

```yaml
repositories:
  - name: "RHEL_9_BaseOS"
    product: "Red Hat Enterprise Linux Server"
    content_type: "yum"
    url: "https://cdn.redhat.com/content/dist/rhel/rhel-9/..."
    download_policy: "immediate"
```

## Sync Plans Configuration

```yaml
sync_plans:
  - name: "Daily_Sync"
    organization: "Default Organization"
    interval: "daily"
    sync_date: "2024-01-01 00:00:00"
    enabled: true
```

## Repository Sets Configuration - Enable RHEL Yum Repositories

The role automatically enables official RHEL repository sets for all configured products:

```yaml
enable_repository_sets: true
repository_sets_to_enable:
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

This ensures RHEL BaseOS and AppStream repositories are automatically enabled for both RHEL 9 and RHEL 10 products.

## Usage Examples

### Configure Basic Content Infrastructure
```yaml
- name: Configure Satellite Content
  hosts: satellite
  roles:
    - role: satellite_content_config
      vars:
        create_organizations: true
        create_locations: true
        create_sync_plans: true
```

### Configure with Repositories and Repository Sets
```yaml
- role: satellite_content_config
  vars:
    create_repositories: true
    synchronize_repositories: true
    enable_repository_sets: true
```

### Disable Repository Set Enablement
```yaml
- role: satellite_content_config
  vars:
    enable_repository_sets: false  # Skip auto-enabling RHEL repos
```

## Output

- Organizations created/updated
- Locations configured
- Products created
- Repositories configured
- RHEL yum repositories enabled for products
- Sync plans established

## Integration

Works with:
- satellite_6_18_deployment (core installation)
- satellite_lifecycle_config (lifecycle environments)
- satellite_activation_config (activation keys)

## Security Considerations

- All passwords stored in Ansible vault
- SSL certificate validation enabled
- API credentials protected
- No sensitive data logged

## Dependencies

- redhat.satellite collection
- Satellite 6.18 deployed and running

## Author

Red Hat Management Team

## License

Apache-2.0
