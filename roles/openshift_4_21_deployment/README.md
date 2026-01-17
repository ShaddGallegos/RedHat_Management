# Role: openshift_4_21_deployment

## Description

The `openshift_4_21_deployment` role handles OpenShift Container Platform 4.21 deployment with all components specific to RHIS.

**Key Responsibility**: Deploy OpenShift 4.21 for RHIS.

## When to Use

- Deploying OpenShift 4.21
- Container platform setup
- RHIS OpenShift integration

## Features

- **Complete Deployment**: Full OCP stack
- **RHIS Integration**: RHIS-specific features
- **Product Integration**: OCP integrations

## Usage Examples

```yaml
- name: Deploy OpenShift 4.21
  hosts: localhost
  roles:
    - role: openshift_4_21_deployment
```

## Support & Documentation

See orchestration_master README for integration.

## Author

Red Hat Management Team

## License

Apache-2.0
