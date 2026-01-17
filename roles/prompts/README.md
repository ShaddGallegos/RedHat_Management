# Role: prompts

## Description

The `prompts` role manages user interaction and prompting for deployment configuration and variables.

**Key Responsibility**: Handle user prompts and inputs.

## When to Use

- Interactive deployments
- Configuration prompts
- User input collection
- Variable solicitation

## Features

- **User Prompts**: Interactive prompts
- **Input Validation**: Validate inputs
- **Default Values**: Provide defaults
- **Help Text**: Provide guidance

## Usage Examples

```yaml
- name: Run Prompts
  hosts: localhost
  roles:
    - role: prompts
```

## Support & Documentation

See orchestration_master README for integration.

## Author

Red Hat Management Team

## License

Apache-2.0
