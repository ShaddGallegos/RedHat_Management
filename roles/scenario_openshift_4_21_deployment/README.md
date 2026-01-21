# Role: scenario_openshift_4_21_deployment

## Description

The `scenario_openshift_4_21_deployment` role handles OpenShift Container Platform 4.21 deployment with all components specific to RHIS.

**Key Responsibility**: Deploy OpenShift 4.21 for RHIS.

## When to Use

- Deploying OpenShift 4.21
- Container platform setup
- RHIS OpenShift integration_generic

## Features

- **Complete Deployment**: Full OCP stack
- **RHIS Integration**: RHIS-specific features
- **Product Integration**: OCP integrations

## Usage Examples

```yaml
- name: Deploy OpenShift 4.21
  hosts: localhost
  roles:
    - role: scenario_openshift_4_21_deployment
```

## Support & Documentation

See ansible_dev_node_orchestration_master README for integration_generic.

## Author

Red Hat Management Team

## License

Apache-2.0
