# Role: scenario_aap_templates

## Description

The `scenario_aap_templates` role configures job templates and workflow templates in Ansible Automation Platform (AAP). Templates define how playbooks are executed with specific inventories, credentials, and configurations.

**Key Responsibility**: Configure and manage AAP templates for RHIS deployments.

## When to Use

- Setting up AAP job templates for RHIS
- Creating workflow orchestrations
- Configuring playbook execution parameters
- Template lifecycle management

## Features

- **Job Templates**: Single playbook execution templates
- **Workflow Templates**: Multi-step ansible_dev_node_orchestration workflows
- **Credentials**: Integration with multiple credential types
- **Variables**: Extra variables and inventory options
- **Execution Settings**: Verbosity, limits, and tags
- **Prompts**: Ask on launch for variables/inventory

## Required Variables

```yaml
scenario_aap_templates_aap_url: "https://aap.example.com"
scenario_aap_templates_aap_username: "admin"
aap_password: "{{ vault_aap_admin_pwd }}"
```

## Optional Variables

```yaml
scenario_aap_templates_aap_templates_organization: "Default"
scenario_aap_templates_create_job_templates: true
scenario_aap_templates_create_workflow_templates: true
scenario_aap_templates_aap_templates_ask_variables: false
```

## Template Types

### Job Templates
Single playbook execution
```yaml
scenario_aap_templates_job_templates:
  - name: "RHIS_Deploy_Infrastructure"
    inventory: "RHIS_Infrastructure"
    project: "RHIS_Playbooks"
    playbook: "playbooks/deploy_components.yml"
    credential: "RHIS_SSH_Key"
    verbosity: 1
    tags: ["rhis", "deploy"]
```

### Workflow Templates
Multi-step ansible_dev_node_orchestration
```yaml
scenario_aap_templates_workflow_templates:
  - name: "RHIS_Complete_Deployment"
    description: "Complete RHIS workflow"
    organization: "Default"
```

## Usage Examples

### Configure All Templates
```yaml
- name: Configure AAP Templates
  hosts: localhost
  roles:
    - role: scenario_aap_templates
      vars:
        scenario_aap_templates_create_job_templates: true
        scenario_aap_templates_create_workflow_templates: true
```

### Configure with Prompts
```yaml
- role: scenario_aap_templates
  vars:
    scenario_aap_templates_job_templates:
      - name: "RHIS_Deploy"
        ask_inventory: true
        ask_variables: true
```

## Output

- Job templates created and validated
- Workflow templates configured
- Template summary displayed
- Execution parameters set

## Security Features

- Vault credential integration_generic
- SSH key credential ansible_dev_node_support
- Credential isolation per organization
- Ask on launch for sensitive inputs

## Dependencies

- scenario_aap_credentials (for credentials)
- scenario_aap_inventories (for inventories)
- scenario_aap_projects (for projects)

## Author

Red Hat Management Team

## License

Apache-2.0
