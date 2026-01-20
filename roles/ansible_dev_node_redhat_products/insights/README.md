# Role: ansible_dev_node_redhat_products/insights

## Description

The `ansible_dev_node_redhat_products/insights` role configures integration_generic with Red Hat Insights for predictive analytics, vulnerability management, and automated remediation.

**Key Responsibility**: Configure Insights integration_generic for products.

## When to Use

- Enabling vulnerability management
- Predictive analytics
- Compliance monitoring
- Security analytics

## Features

- **Vulnerability Management**: Track and remediate
- **Compliance Monitoring**: Compliance tracking
- **Predictive Analytics**: AI-driven insights
- **Automated Remediation**: Auto-fix vulnerabilities

## Usage Examples

```yaml
- name: Configure Insights
  hosts: all
  roles:
    - role: ansible_dev_node_redhat_products/insights
```

## Support & Documentation

See ansible_dev_node_orchestration_master README for integration_generic.

## Author

Red Hat Management Team

## License

Apache-2.0
