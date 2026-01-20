# Common Tasks Role

Shared task files used across all products and roles to eliminate duplication.

## Overview

This role provides reusable task files for common operations:
- System updates and package management
- Time synchronization (NTP/Chrony)
- Repository configuration
- Global parameter management
- Environment configuration

## Task Files

### system_updates.yml
Updates OS packages and handles repository caching.

**Variables:**
```yaml
update_strategy: "latest"  # latest or security
```

**Tags:** `system`, `updates`

**Usage:**
```yaml
- name: Update system packages
  ansible.builtin.import_tasks: roles/common_tasks/tasks/system_updates.yml
```

### time_sync.yml
Installs and configures time synchronization via Chrony.

**Variables:**
```yaml
ntp_servers:
  - "0.rhel.pool.ntp.org"
  - "1.rhel.pool.ntp.org"
```

**Tags:** `time`, `ntp`

**Usage:**
```yaml
- name: Configure time synchronization
  ansible.builtin.import_tasks: roles/common_tasks/tasks/time_sync.yml
  vars:
    ntp_servers:
      - "ntp.example.com"
      - "ntp2.example.com"
```

### repositories.yml
Enables subscriptions and repository management.

**Variables:**
```yaml
repositories: []          # List of repos to enable
scap_file: null          # SCAP file for compliance
scap_profile: "xccdf_org.ssgproject.content_profile_cis"
```

**Tags:** `repositories`, `subscriptions`, `compliance`, `scap`

**Usage:**
```yaml
- name: Configure repositories
  ansible.builtin.import_tasks: roles/common_tasks/tasks/repositories.yml
  vars:
    repositories:
      - name: "rhel-9-appstream-rpms"
      - name: "rhel-9-baseos-rpms"
```

### configuration.yml
Applies global configuration parameters and environment settings.

**Variables:**
```yaml
environment: "development"           # development or production
mandatory_global_parameters: []      # Global config parameters
mandatory_os_config: []              # OS-specific config
```

**Tags:** `configuration`, `parameters`, `environment`

**Usage:**
```yaml
- name: Configure environment
  ansible.builtin.import_tasks: roles/common_tasks/tasks/configuration.yml
  vars:
    environment: "production"
    mandatory_global_parameters:
      - key: "timeout"
        value: 300
```

## Best Practices

1. **Import vs Include**: Use `import_tasks` for static imports, `include_tasks` for dynamic
2. **Handlers**: Define handlers in the including role
3. **Variables**: Pass via `vars:` parameter or use role defaults
4. **Tags**: All tasks tagged for selective execution
5. **Notifications**: Tasks notify handlers defined in calling role

## Example: Full Product Setup

```yaml
- name: Complete AAP Setup
  hosts: aap
  roles:
    - common_tasks  # Include common tasks as dependency
    - aap # Product-specific setup

  tasks:
    - name: Update system
      ansible.builtin.import_tasks: roles/common_tasks/tasks/system_updates.yml

    - name: Configure time
      ansible.builtin.import_tasks: roles/common_tasks/tasks/time_sync.yml

    - name: Configure repositories
      ansible.builtin.import_tasks: roles/common_tasks/tasks/repositories.yml
      vars:
        repositories:
          - name: "rhel-9-appstream-rpms"
          - name: "rhel-9-baseos-rpms"
```

## Avoiding Duplication

Before creating a new task:
1. Check if it exists in `common_tasks/tasks/`
2. If similar task exists, consider consolidating
3. Extract common patterns into new task files
4. Document new task files in this README

## Extending Common Tasks

To add a new common task file:

1. Create `roles/common_tasks/tasks/new_feature.yml`
2. Add variables to `roles/common_tasks/defaults/main.yml`
3. Document in this README
4. Add to main.yml import chain (or reference in documentation)
5. Tag all tasks appropriately

## Collections Used

- `ansible.builtin.*` - Core modules
- `ansible.posix.*` - POSIX modules (rhsm_repository)

## See Also

- [Product Lifecycle Roles](../product_lifecycle/README.md)
- [Support Roles](../support/README.md)
- [Product Roles](../redhat_products/README.md)
