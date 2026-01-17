# Role: redhat_products/insights

## Description

The `redhat_products/insights` role configures integration with Red Hat Insights for predictive analytics, vulnerability management, and automated remediation.

**Key Responsibility**: Configure Insights integration for products.

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
    - role: redhat_products/insights
```

## Support & Documentation

See orchestration_master README for integration.

## Author

Red Hat Management Team

## License

Apache-2.0
