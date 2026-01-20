# Role: aap_credentials_config

## Description

The `aap_credentials_config` role configures credentials in Ansible Automation Platform (AAP). It manages the creation and configuration of all credential types needed for RHIS deployments.

**Key Responsibility**: Configure and manage AAP credentials for automation.

## When to Use

- Setting up AAP credentials for RHIS
- Configuring SSH, vault, registry, and cloud credentials
- Post-AAP deployment configuration
- Credential lifecycle management

## Features

- **Machine Credentials**: SSH keys and sudo configuration
- **Vault Credentials**: Ansible vault integration
- **Registry Credentials**: Container registry access
- **Satellite Credentials**: Satellite API integration
- **Cloud Credentials**: AWS, Azure, GCP support
- **Validation**: Connection testing and verification

## Requirements

- AAP already deployed and running
- AAP admin user access
- SSH keys available
- Vault passwords configured
- Cloud credentials (if using cloud)

## Required Variables

```yaml
aap_url: "https://aap.example.com"
aap_username: "admin"
aap_password: "{{ vault_aap_admin_pwd }}"
```

## Optional Variables

```yaml
aap_credentials_organization: "Default"
create_machine_credentials: true
create_vault_credentials: true
create_registry_credentials: true
create_satellite_credentials: true
aap_credentials_test_connections: true
```

## Credential Types Supported

### Machine Credentials
SSH keys for host management
```yaml
machine_credentials:
  - name: "RHIS_SSH_Key"
    username: "ansible"
    ssh_key_data: "~/.ssh/id_rsa"
    become_method: "sudo"
```

### Vault Credentials
Ansible vault passwords
```yaml
vault_credentials:
  - name: "RHIS_Vault"
    vault_password: "{{ vault_password }}"
```

### Registry Credentials
Container registry access
```yaml
registry_credentials:
  - name: "RedHat_Registry"
    host: "registry.redhat.io"
    username: "{{ rhel_user }}"
    password: "{{ vault_registry_pwd }}"
```

### Satellite Credentials
Satellite API access
```yaml
satellite_credentials:
  - name: "Satellite_API"
    host: "satellite.example.com"
    username: "admin"
    password: "{{ vault_satellite_pwd }}"
```

## Usage Examples

### Configure All Credentials
```yaml
- name: Configure AAP Credentials
  hosts: localhost
  roles:
    - role: aap_credentials_config
      vars:
        aap_url: "https://aap.prod.example.com"
        aap_username: "admin"
        aap_password: "{{ vault_aap_admin_pwd }}"
        create_machine_credentials: true
        create_vault_credentials: true
        create_registry_credentials: true
```

### Configure Specific Credential Type
```yaml
- role: aap_credentials_config
  vars:
    create_machine_credentials: true
    create_vault_credentials: false
    create_registry_credentials: false
    create_satellite_credentials: false
```

## Output

- Credentials created in AAP organization
- Authentication tokens validated
- Connection tests passed
- Credential summary displayed

## Common Issues & Resolution

### Issue: "Invalid API token"
**Cause**: AAP credentials incorrect
**Resolution**: Verify aap_username and aap_password

### Issue: "SSH key not found"
**Cause**: SSH key path incorrect
**Resolution**: Verify ssh_key_data path exists

### Issue: "Organization not found"
**Cause**: Organization doesn't exist
**Resolution**: Create organization first or update name

## Security Considerations

- Store all passwords in Ansible vault
- Use SSH keys instead of passwords where possible
- Restrict credential access by organization
- Rotate credentials regularly
- Audit credential usage

## Dependencies

None (AAP must be running)

## Author

Red Hat Management Team

## License

Apache-2.0
