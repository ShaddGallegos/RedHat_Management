# Role: satellite_6_18_deployment

## Description

The `satellite_6_18_deployment` role handles complete Satellite 6.18 deployment with all components and configurations specific to RHIS.

**Key Responsibility**: Deploy complete Satellite 6.18 for RHIS.

## When to Use

- Deploying Satellite 6.18
- RHIS Satellite integration
- Full Satellite stack

## Features

- **Complete Deployment**: Full Satellite stack
- **RHIS Integration**: RHIS-specific features
- **Product Integration**: Satellite integrations

## Usage Examples

```yaml
- name: Deploy Satellite 6.18
  hosts: localhost
  roles:
    - role: satellite_6_18_deployment
```

## Support & Documentation

See orchestration_master README for integration.

## Author

Red Hat Management Team

## License

Apache-2.0
