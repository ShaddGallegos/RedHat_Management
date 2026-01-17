# Variable Naming Convention Standard

## Overview

This document establishes the standardized variable naming convention for all roles in the RHIS (Red Hat Infrastructure Standard) project. This convention ensures consistency, readability, and maintainability across the entire codebase.

## Convention Pattern

### Base Pattern

```
{{ role_name }}_{{ category }}_{{ property }}
```

### Examples

- `aap_enabled` - Enable/disable AAP
- `aap_version` - AAP version
- `satellite_timeout` - Satellite operation timeout
- `satellite_port` - Satellite port number
- `infrastructure_manager_max_retries` - Infrastructure manager retry count

## Standard Variable Types

### 1. Feature Toggles

**Pattern**: `{{ role_name }}_enabled`

```yaml
aap_enabled: true
satellite_enabled: true
idm_enabled: false
```

### 2. Versions

**Pattern**: `{{ role_name }}_version`

```yaml
aap_version: "2.6"
satellite_version: "6.18"
openshift_version: "4.21"
```

### 3. Hostnames/URLs

**Pattern**: `{{ role_name }}_hostname` or `{{ role_name }}_url`

```yaml
aap_hostname: "aap.example.com"
satellite_hostname: "satellite.example.com"
idm_hostname: "idm.example.com"
aap_url: "https://aap.example.com"
satellite_url: "https://satellite.example.com"
```

### 4. Ports

**Pattern**: `{{ role_name }}_port`

```yaml
aap_port: 443
satellite_port: 443
idm_port: 636  # LDAPS
postgres_port: 5432
```

### 5. Timeouts

**Pattern**: `{{ role_name }}_timeout` (in seconds)

```yaml
aap_timeout: 3600
satellite_timeout: 7200
deployment_timeout: 86400
```

### 6. Retry Counts

**Pattern**: `{{ role_name }}_retries` or `{{ role_name }}_max_retries`

```yaml
aap_retries: 3
satellite_retries: 5
deployment_max_retries: 10
```

### 7. Resource Limits

**Pattern**: `{{ role_name }}_{{ resource_type }}_{{ limit }}`

```yaml
aap_memory_mb: 16384
aap_cpu_cores: 8
satellite_disk_gb: 500
database_pool_size: 50
```

### 8. Credentials

**Pattern**: `{{ role_name }}_{{ cred_type }}_{{ property }}`

```yaml
aap_admin_username: "admin"
aap_admin_password: "{{ vault_aap_admin_pwd }}"
satellite_api_token: "{{ vault_satellite_token }}"
idm_admin_password: "{{ vault_idm_pwd }}"
```

### 9. Lists/Arrays

**Pattern**: `{{ role_name }}_{{ plural_item }}`

```yaml
aap_organizations:
  - "Default"
  - "Production"
satellite_repositories:
  - "rhel-9-baseos"
  - "rhel-9-appstream"
idm_replica_hostnames:
  - "idm-replica1.example.com"
  - "idm-replica2.example.com"
```

### 10. Configuration Maps

**Pattern**: `{{ role_name }}_{{ config_name }}`

```yaml
aap_rbac_config:
  admins: ["admin", "devops-lead"]
  operators: ["operator1", "operator2"]
  viewers: ["viewer1"]

satellite_org_config:
  name: "Default Organization"
  description: "Main organization"
```

### 11. Feature Flags

**Pattern**: `{{ role_name }}_enable_{{ feature_name }}`

```yaml
aap_enable_ldap: true
satellite_enable_insights: true
idm_enable_replication: false
```

### 12. Integration Flags

**Pattern**: `configure_{{ product1 }}_{{ product2 }}_integration`

```yaml
configure_satellite_aap_integration: true
configure_satellite_idm_integration: true
configure_aap_idm_integration: true
```

## Role-Specific Variables

### AAP Variables

```yaml
aap_enabled: true
aap_version: "2.6"
aap_hostname: "aap.example.com"
aap_port: 443
aap_timeout: 3600
aap_max_retries: 3
aap_memory_mb: 16384
aap_cpu_cores: 8
aap_admin_username: "admin"
aap_admin_password: "{{ vault_aap_admin_pwd }}"
aap_organizations: ["Default", "Production"]
aap_enable_ldap: true
aap_enable_eda: true
configure_aap_rbac: true
```

### Satellite Variables

```yaml
satellite_enabled: true
satellite_version: "6.18"
satellite_hostname: "satellite.example.com"
satellite_port: 443
satellite_timeout: 7200
satellite_max_retries: 5
satellite_disk_gb: 500
satellite_admin_username: "admin"
satellite_admin_password: "{{ vault_satellite_pwd }}"
satellite_api_token: "{{ vault_satellite_token }}"
satellite_repositories: ["rhel-9-baseos", "rhel-9-appstream"]
satellite_enable_insights: true
configure_satellite_api: true
```

### IdM Variables

```yaml
idm_enabled: true
idm_version: "3.0"
idm_realm: "EXAMPLE.COM"
idm_domain: "example.com"
idm_hostname: "idm.example.com"
idm_port: 636
idm_timeout: 1800
idm_max_retries: 3
idm_admin_username: "admin"
idm_admin_password: "{{ vault_idm_pwd }}"
idm_dm_password: "{{ vault_idm_dm_pwd }}"
idm_enable_replication: false
idm_replica_hostnames: []
```

### Infrastructure Variables

```yaml
infrastructure_enabled: true
infrastructure_timeout: 1800
infrastructure_max_retries: 3
deploy_infrastructure: true
infrastructure_platform: "libvirt"
infrastructure_network: "default"
```

### Deployment Variables

```yaml
deployment_scenario: "satellite_aap"
deployment_platform: "libvirt"
deployment_os: "rhel-9"
deployment_timeout: 86400
deployment_max_retries: 10
```

## Naming Do's and Don'ts

### ✅ DO

- Use lowercase with underscores
- Start with role name
- Use descriptive property names
- Be consistent across similar variables
- Use singular/plural appropriately
- Include units in variable names (e.g., `_mb`, `_gb`, `_seconds`)

### ❌ DON'T

- Use CamelCase or mixed case
- Use hyphens instead of underscores
- Create overly abbreviated names
- Use role prefixes inconsistently
- Mix plural and singular forms
- Omit units for numeric values

## Examples of Good vs Bad

| Good | Bad | Reason |
|------|-----|--------|
| `aap_admin_password` | `AAP_AdminPassword` | Consistency, case, format |
| `satellite_timeout` | `sat_timeout` | Full role name, clarity |
| `idm_replica_hostnames` | `idm_replicas` | Clarity on what's included |
| `aap_memory_mb` | `aap_memory` | Includes unit specification |
| `deploy_infrastructure` | `deploy_infra` | Full descriptive names |
| `satellite_port` | `satellite_p` | Avoid abbreviations |
| `configure_aap_rbac` | `setup_rbac` | Clear product reference |

## Variable Placement

### defaults/main.yml

Contains all default variable definitions:

```yaml
---
# Enable/disable role
{{ role_name }}_enabled: true

# Version information
{{ role_name }}_version: "X.Y"

# Timeout and retry settings
{{ role_name }}_timeout: 3600
{{ role_name }}_max_retries: 3

# Feature flags
{{ role_name }}_enable_feature: true
```

### vars/main.yml

Contains non-overridable variables:

```yaml
---
# Internal computed variables
{{ role_name }}_internal_version: "{{ {{ role_name }}_version | parse_version }}"
```

### group_vars/host_vars

Contains environment-specific overrides:

```yaml
---
aap_hostname: "aap.prod.example.com"
satellite_hostname: "satellite.prod.example.com"
```

## Migration Guide

### Converting Existing Variables

**Old Style:**
```yaml
aap_password: "secret"
satellite_timeout: 3600
enable_idm: true
```

**New Style:**
```yaml
aap_admin_password: "{{ vault_aap_admin_pwd }}"
satellite_timeout: 3600  # Already good
idm_enabled: true
```

## Validation

### Automated Checks

All role `defaults/main.yml` files should conform to this convention. Validation checks:

1. All variables start with `{{ role_name }}_`
2. No CamelCase variable names
3. No hyphenated variable names
4. Consistent naming patterns within role
5. All numeric values include units

### Manual Review Checklist

- [ ] All variables follow the pattern
- [ ] Related variables use consistent suffixes
- [ ] Credentials marked with vault references
- [ ] Units specified for numeric values
- [ ] Feature toggles use `_enabled` suffix
- [ ] Documentation updated

## Examples by Role

### AAP Role (redhat_products/aap)

```yaml
defaults/main.yml:
---
# Core settings
aap_enabled: true
aap_version: "2.6"

# Connectivity
aap_hostname: "aap.example.com"
aap_port: 443

# Performance
aap_timeout: 3600
aap_max_retries: 3
aap_memory_mb: 16384
aap_cpu_cores: 8

# Credentials (use vault!)
aap_admin_username: "admin"
aap_admin_password: "{{ vault_aap_admin_pwd }}"

# Features
aap_enable_ldap: true
aap_enable_eda: true
aap_organizations: ["Default", "Production"]

# Configuration
configure_aap_rbac: true
```

### Satellite Role (redhat_products/satellite)

```yaml
defaults/main.yml:
---
# Core settings
satellite_enabled: true
satellite_version: "6.18"

# Connectivity
satellite_hostname: "satellite.example.com"
satellite_port: 443
satellite_url: "https://{{ satellite_hostname }}"

# Performance
satellite_timeout: 7200
satellite_max_retries: 5
satellite_disk_gb: 500

# Credentials
satellite_admin_username: "admin"
satellite_admin_password: "{{ vault_satellite_pwd }}"
satellite_api_token: "{{ vault_satellite_token }}"

# Features
satellite_enable_insights: true
satellite_repositories:
  - "rhel-9-baseos"
  - "rhel-9-appstream"

# Configuration
configure_satellite_api: true
configure_satellite_content: true
```

## Questions & Clarifications

**Q: What about common variables used across multiple roles?**  
A: Each role should prefix with its own name. Use group_vars for shared configurations.

**Q: Can I use role aliases?**  
A: No, always use the full role name for consistency and clarity.

**Q: What about third-party product variables?**  
A: Prefix with the RHIS role that manages it. Example: `satellite_foreman_username`.

**Q: Should integration variables use both product names?**  
A: Yes: `configure_{{ product1 }}_{{ product2 }}_integration`. Order alphabetically when possible.

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2026-01-16 | 1.0 | Initial standard established |

## Author

Red Hat Management Team

## License

Apache-2.0
