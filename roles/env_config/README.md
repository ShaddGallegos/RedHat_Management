# env_config Role

This role prompts for environment variables (API URL, token, hosts, groups, integration name) and writes them to defaults/main.yml for use in automation and dynamic inventory plugins.

## Usage

Add this role to your playbook:

```yaml
- hosts: localhost
  roles:
    - env_config
```

You will be prompted for required variables. The role will generate defaults/main.yml with your answers.

## Customization
- Extend vars_prompt in tasks/main.yml for additional variables (e.g., network config, cloud provider, etc.)
- Use the generated defaults/main.yml in other roles or plugins.
