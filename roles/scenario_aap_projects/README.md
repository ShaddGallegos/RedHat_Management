# Role: scenario_aap_projects

## Description

The `scenario_aap_projects` role configures projects in Ansible Automation Platform (AAP). Projects contain playbooks and roles sourced from Git repositories or manually uploaded content.

**Key Responsibility**: Configure and manage AAP projects.

## When to Use

- Setting up AAP projects for RHIS
- Creating Git-based projects
- Managing playbook repositories
- Project synchronization

## Features

- **Git Projects**: Repository-based projects with auto-sync
- **Manual Projects**: Manually uploaded playbooks
- **Auto-sync**: Update projects on launch
- **Branching**: Support for specific branches
- **Credentials**: Git credential ansible_dev_node_support

## Required Variables

```yaml
scenario_aap_projects_aap_url: "https://aap.example.com"
scenario_aap_projects_aap_username: "admin"
aap_password: "{{ vault_aap_admin_pwd }}"
```

## Optional Variables

```yaml
scenario_aap_projects_aap_projects_organization: "Default"
scenario_aap_projects_create_git_projects: true
scenario_aap_projects_create_manual_projects: true
scenario_aap_projects_aap_projects_sync_on_create: true
```

## Project Types

### Git Projects
Repository-based projects
```yaml
scenario_aap_projects_git_projects:
  - name: "RHIS_Playbooks"
    scm_url: "https://github.com/example/rhis.git"
    scm_branch: "main"
    update_on_launch: true
```

### Manual Projects
Manual playbook projects
```yaml
scenario_aap_projects_manual_projects:
  - name: "RHIS_Local"
    description: "Local playbooks"
```

## Usage Examples

### Configure All Projects
```yaml
- name: Configure AAP Projects
  hosts: localhost
  roles:
    - role: scenario_aap_projects
      vars:
        scenario_aap_projects_create_git_projects: true
        scenario_aap_projects_create_manual_projects: true
        scenario_aap_projects_aap_projects_sync_on_create: true
```

## Dependencies

None (AAP must be running)

## Author

Red Hat Management Team

## License

Apache-2.0
