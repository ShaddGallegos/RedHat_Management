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
ansible_dev_node_common_tasks_update_strategy: "latest"  # latest or security
```

**Tags:** `system`, `updates`

**Usage:**
```yaml
- name: Update system packages
  ansible.builtin.import_tasks: roles/ansible_dev_node_common_tasks/tasks/system_updates.yml
```

### time_sync.yml
Installs and configures time synchronization via Chrony.

**Variables:**
```yaml
ansible_dev_node_common_tasks_ntp_servers:
  - "0.rhel.pool.ntp.org"
  - "1.rhel.pool.ntp.org"
```

**Tags:** `time`, `ntp`

**Usage:**
```yaml
- name: Configure time synchronization
  ansible.builtin.import_tasks: roles/ansible_dev_node_common_tasks/tasks/time_sync.yml
  vars:
    ansible_dev_node_common_tasks_ntp_servers:
      - "ntp.example.com"
      - "ntp2.example.com"
```

### ansible_dev_node_common_tasks_repositories.yml
Enables subscriptions and repository management.

**Variables:**
```yaml
ansible_dev_node_common_tasks_repositories: []          # List of repos to enable
ansible_dev_node_common_tasks_scap_file: null          # SCAP file for compliance
ansible_dev_node_common_tasks_scap_profile: "xccdf_org.ssgproject.content_profile_cis"
```

**Tags:** `ansible_dev_node_common_tasks_repositories`, `subscriptions`, `compliance`, `scap`

**Usage:**
```yaml
- name: Configure ansible_dev_node_common_tasks_repositories
  ansible.builtin.import_tasks: roles/ansible_dev_node_common_tasks/tasks/ansible_dev_node_common_tasks_repositories.yml
  vars:
    ansible_dev_node_common_tasks_repositories:
      - name: "rhel-9-appstream-rpms"
      - name: "rhel-9-baseos-rpms"
```

### configuration.yml
Applies global configuration parameters and ansible_dev_node_common_tasks_environment settings.

**Variables:**
```yaml
ansible_dev_node_common_tasks_environment: "development"           # development or production
ansible_dev_node_common_tasks_mandatory_global_parameters: []      # Global config parameters
ansible_dev_node_common_tasks_mandatory_os_config: []              # OS-specific config
```

**Tags:** `configuration`, `parameters`, `ansible_dev_node_common_tasks_environment`

**Usage:**
```yaml
- name: Configure ansible_dev_node_common_tasks_environment
  ansible.builtin.import_tasks: roles/ansible_dev_node_common_tasks/tasks/configuration.yml
  vars:
    ansible_dev_node_common_tasks_environment: "production"
    ansible_dev_node_common_tasks_mandatory_global_parameters:
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
    - ansible_dev_node_common_tasks  # Include common tasks as dependency
    - scenario_aap_setup # Product-specific setup

  tasks:
    - name: Update system
      ansible.builtin.import_tasks: roles/ansible_dev_node_common_tasks/tasks/system_updates.yml

    - name: Configure time
      ansible.builtin.import_tasks: roles/ansible_dev_node_common_tasks/tasks/time_sync.yml

    - name: Configure ansible_dev_node_common_tasks_repositories
      ansible.builtin.import_tasks: roles/ansible_dev_node_common_tasks/tasks/ansible_dev_node_common_tasks_repositories.yml
      vars:
        ansible_dev_node_common_tasks_repositories:
          - name: "rhel-9-appstream-rpms"
          - name: "rhel-9-baseos-rpms"
```

## Avoiding Duplication

Before creating a new task:
1. Check if it exists in `ansible_dev_node_common_tasks/tasks/`
2. If similar task exists, consider consolidating
3. Extract common patterns into new task files
4. Document new task files in this README

## Extending Common Tasks

To add a new common task file:

1. Create `roles/ansible_dev_node_common_tasks/tasks/new_feature.yml`
2. Add variables to `roles/ansible_dev_node_common_tasks/defaults/main.yml`
3. Document in this README
4. Add to main.yml import chain (or reference in documentation)
5. Tag all tasks appropriately

## Collections Used

- `ansible.builtin.*` - Core modules
- `ansible.posix.*` - POSIX modules (rhsm_repository)

## See Also

- [Product Lifecycle Roles](../ansible_dev_node_product_lifecycle/README.md)
- [Support Roles](../ansible_dev_node_support/README.md)
- [Product Roles](../ansible_dev_node_redhat_products/README.md)
