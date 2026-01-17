# Role: satellite_activation_config

## Description

The `satellite_activation_config` role configures Satellite 6.18 activation keys, subscriptions, host collections, and repository enablement.

**Key Responsibility**: Configure activation keys for managed system registration.

## When to Use

- Setting up activation keys for host registration
- Attaching subscriptions to keys
- Enabling repository sets
- Configuring host collections
- Managing system repositories

## Features

- **Activation Keys**: Create keys for different environments
- **Host Collections**: Group and organize managed hosts
- **Subscriptions**: Attach subscriptions to activation keys
- **Repository Sets**: Enable specific repositories
- **Usage Limits**: Control activation key usage
- **Auto-attach**: Automatic subscription attachment

## Required Variables

```yaml
satellite_url: "https://satellite.example.com"
satellite_username: "admin"
satellite_password: "{{ vault_satellite_admin_pwd }}"
```

## Activation Keys

```yaml
activation_keys:
  - name: "RHEL9_BaseOS"
    lifecycle_environment: "Library"
    content_view: "RHIS_BaseOS"
    usage_limit: -1
    auto_attach: true
    release_version: "9"
```

## Host Collections

```yaml
host_collections:
  - name: "RHIS_Production"
    description: "Production hosts"
    organization: "Default Organization"
```

## Subscription Attachments

```yaml
subscription_attachments:
  - activation_key: "RHEL9_BaseOS"
    subscription: "Red Hat Enterprise Linux Server"
    quantity: 100
```

## Usage Examples

### Configure Activation Keys
```yaml
- name: Configure Satellite Activation Keys
  hosts: satellite
  roles:
    - role: satellite_activation_config
      vars:
        create_activation_keys: true
        attach_subscriptions: true
```

### Configure with Host Collections
```yaml
- role: satellite_activation_config
  vars:
    configure_host_collections: true
    create_activation_keys: true
```

## Output

- Activation keys created
- Host collections configured
- Subscriptions attached
- Repository sets enabled
- Summary displayed

## Integration

Works with:
- satellite_content_config (repositories)
- satellite_lifecycle_config (environments)

## Security Considerations

- All passwords stored in vault
- SSL certificate validation
- API credentials protected
- No sensitive data logged

## Host Registration

Register hosts with created activation keys:
```bash
subscription-manager register \
  --org="Default Organization" \
  --activationkey="RHEL9_BaseOS" \
  --server-hostname=satellite.example.com
```

## Dependencies

- redhat.satellite collection
- Satellite 6.18 with content configured

## Author

Red Hat Management Team

## License

Apache-2.0
