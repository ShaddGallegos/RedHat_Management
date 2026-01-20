# Role: aap_templates

## Description

The `aap_templates` role configures job templates and workflow templates in Ansible Automation Platform (AAP). Templates define how playbooks are executed with specific inventories, credentials, and configurations.

**Key Responsibility**: Configure and manage AAP templates for RHIS deployments.

## When to Use

- Setting up AAP job templates for RHIS
- Creating workflow orchestrations
- Configuring playbook execution parameters
- Template lifecycle management

## Features

- **Job Templates**: Single playbook execution templates
- **Workflow Templates**: Multi-step orchestration workflows
- **Credentials**: Integration with multiple credential types
- **Variables**: Extra variables and inventory options
- **Execution Settings**: Verbosity, limits, and tags
- **Prompts**: Ask on launch for variables/inventory

## Required Variables

```yaml
aap_url: "https://aap.example.com"
aap_username: "admin"
aap_password: "{{ vault_aap_admin_pwd }}"
```

## Optional Variables

```yaml
aap_templates_organization: "Default"
create_job_templates: true
create_workflow_templates: true
aap_templates_ask_variables: false
```

## Template Types

### Job Templates
Single playbook execution
```yaml
job_templates:
  - name: "RHIS_Deploy_Infrastructure"
    inventory: "RHIS_Infrastructure"
    project: "RHIS_Playbooks"
    playbook: "playbooks/deploy_components.yml"
    credential: "RHIS_SSH_Key"
    verbosity: 1
    tags: ["rhis", "deploy"]
```

### Workflow Templates
Multi-step orchestration
```yaml
workflow_templates:
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
    - role: aap_templates
      vars:
        create_job_templates: true
        create_workflow_templates: true
```

### Configure with Prompts
```yaml
- role: aap_templates
  vars:
    job_templates:
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

- Vault credential integration
- SSH key credential support
- Credential isolation per organization
- Ask on launch for sensitive inputs

## Dependencies

- aap_credentials (for credentials)
- aap_inventories (for inventories)
- aap_projects (for projects)

## Author

Red Hat Management Team

## License

Apache-2.0
