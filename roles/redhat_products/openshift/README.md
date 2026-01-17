# Role: redhat_products/openshift

## Description

The `redhat_products/openshift` role orchestrates the deployment of OpenShift Container Platform 4.21+. It coordinates cluster initialization, operator deployment, and containerized workload infrastructure.

**Key Responsibility**: Deploy and configure OpenShift Container Platform.

## When to Use

- Deploying OpenShift clusters
- Container platform infrastructure
- Kubernetes-based deployments
- Modern application delivery

## Features

- **Cluster Deployment**: Full OCP cluster setup
- **Operator Management**: Deploy and manage operators
- **Storage Configuration**: Persistent storage setup
- **Network Configuration**: Network integration
- **RBAC Setup**: User and role management

## Requirements

### System Requirements
- **CPU**: 12+ cores for 3-node cluster
- **Memory**: 48GB minimum
- **Disk**: 300GB minimum
- **OS**: RHEL 9 or RHEL 10

### Network Requirements
- Ports: 443, 6443, 8443
- DNS resolution for cluster
- Network isolated from other products

## Usage Examples

```yaml
- name: Deploy OpenShift
  hosts: localhost
  roles:
    - role: redhat_products/openshift
      vars:
        deployment_scenario: "openshift_only"
```

## Support & Documentation

See orchestration_master README for integration.

## Author

Red Hat Management Team

## License

Apache-2.0
