# Role: orchestration_master

## Description

The `orchestration_master` role is the primary orchestration engine for the RHIS (Red Hat Infrastructure Standard) deployment framework. It coordinates all deployment phases, manages scenario and platform selection, and routes to appropriate product and infrastructure roles.

**Key Responsibility**: Top-level deployment orchestration for all 15 scenarios across 7 platforms.

## When to Use

- Deploying complete Red Hat infrastructure stacks
- Multi-product scenarios (Satellite + AAP, Satellite + IdM, etc.)
- Orchestrating full deployment lifecycle
- Managing complex infrastructure deployments

## Features

- **15 Deployment Scenarios**: From single-product to complete 4-product stacks
- **7 Platform Support**: LibVirt, Bare Metal, AWS, Azure, GCP, VMware, Nutanix
- **Dynamic Routing**: Automatically selects platform-specific tasks
- **Comprehensive Logging**: Detailed deployment tracking and reporting
- **Error Recovery**: Built-in error handling and recovery mechanisms

## Requirements

### Ansible Version
- Minimum: 2.10
- Maximum: 2.16
- Recommended: 2.13+

### Python Modules
- jinja2
- pyyaml

### System Resources
- **CPU**: Varies by scenario (4-24 cores minimum)
- **Memory**: Varies by scenario (8-96 GB minimum)
- **Disk**: Varies by scenario (50-800 GB minimum)

## Required Variables

```yaml
deployment_scenario: "satellite_aap"      # Required: Scenario name
deployment_platform: "libvirt"             # Required: Platform type
deployment_os: "rhel-9"                    # Required: Operating system
install_method: "oemdrv"                   # Optional: Default 'oemdrv'
```

## Optional Variables

```yaml
# Control which phases execute
deploy_infrastructure: true                # Execute infrastructure phase
configure_os: true                         # Execute OS configuration
deploy_products: true                      # Deploy products
run_tests: true                            # Run post-deployment tests

# Product-specific controls
configure_satellite_api: true              # Configure Satellite API
configure_aap_rbac: true                   # Configure AAP RBAC
deploy_idm_replicas: false                 # Deploy IdM replicas
deploy_satellite_reporting: true           # Deploy reporting

# Timing controls
deployment_timeout: 3600                   # Overall timeout (seconds)
operation_retries: 3                       # Retry failed operations
```

## Output

The role provides:
- Complete infrastructure deployment
- Configured products ready for use
- Deployment report and validation
- Health check results

## Usage Examples

### Deploy Satellite Only (LibVirt)
```yaml
- name: Deploy Satellite
  hosts: localhost
  roles:
    - role: orchestration_master
      vars:
        deployment_scenario: "satellite_only"
        deployment_platform: "libvirt"
        deployment_os: "rhel-9"
```

### Deploy Multi-Product Stack (AWS)
```yaml
- name: Deploy Complete Stack
  hosts: localhost
  roles:
    - role: orchestration_master
      vars:
        deployment_scenario: "satellite_aap_idm_openshift"
        deployment_platform: "aws"
        deployment_os: "rhel-10"
        install_method: "tftp"
```

### Deploy with Custom Configuration
```yaml
- name: Custom Deployment
  hosts: localhost
  roles:
    - role: orchestration_master
      vars:
        deployment_scenario: "satellite_aap"
        deployment_platform: "baremetal"
        deployment_os: "rhel-9"
        configure_aap_rbac: true
        deploy_satellite_reporting: true
        deployment_timeout: 7200
```

## Supported Scenarios

### Single Product (4)
- `satellite_only` - Satellite 6.18 only
- `aap_only` - Ansible Automation Platform only
- `idm_only` - Red Hat Identity Management only
- `openshift_only` - OpenShift Container Platform only

### Dual Product (6)
- `satellite_aap` - Satellite + AAP integration
- `satellite_idm` - Satellite + IdM integration
- `satellite_openshift` - Satellite + OpenShift integration
- `aap_idm` - AAP + IdM integration
- `aap_openshift` - AAP + OpenShift integration
- `idm_openshift` - IdM + OpenShift integration

### Triple Product (4)
- `satellite_aap_idm` - Satellite + AAP + IdM
- `satellite_aap_openshift` - Satellite + AAP + OpenShift
- `satellite_idm_openshift` - Satellite + IdM + OpenShift
- `aap_idm_openshift` - AAP + IdM + OpenShift

### Complete Stack (1)
- `satellite_aap_idm_openshift` - All four products

## Supported Platforms

- **libvirt**: Local KVM virtualization (development/testing)
- **baremetal**: Physical servers with PXE boot
- **aws**: Amazon Web Services EC2
- **azure**: Microsoft Azure
- **gcp**: Google Cloud Platform
- **vmware**: VMware vCenter environments
- **nutanix**: Nutanix HCI environments

## Dependencies

| Role | Purpose |
|------|---------|
| deployment_setup | Initialize deployment environment |
| infrastructure_manager | Provision infrastructure |
| inventory_generator | Generate deployment inventory |
| configuration_manager | Manage credentials |
| os | Configure operating system |
| cmdb | Configuration management database |
| integration | Product integrations |
| redhat_products/* | Product deployment |
| support | Post-deployment validation |

## Outputs

After successful execution:
- `/var/log/deployment.log` - Deployment log
- `/opt/rhis/reports/deployment_summary.html` - Deployment report
- `/opt/rhis/inventory/hosts.generated` - Generated inventory

## Common Issues & Resolution

### Issue: "Invalid scenario"
**Cause**: Scenario name not in supported list
**Resolution**: Check `rhis_valid_scenarios` variable

### Issue: "Platform not supported"
**Cause**: Platform name not recognized
**Resolution**: Check `rhis_valid_platforms` variable

### Issue: "Infrastructure provisioning failed"
**Cause**: Platform-specific issues
**Resolution**: Check infrastructure_manager error messages

## Performance Considerations

- **Satellite deployment**: 45-60 minutes
- **AAP deployment**: 20-30 minutes
- **IdM deployment**: 15-20 minutes
- **OpenShift deployment**: 60-90 minutes
- **Complete stack**: 150-180 minutes

## Security Considerations

- Requires elevated privileges for infrastructure provisioning
- Credentials stored in Ansible vault
- Network access required to target platforms
- Firewall rules must allow product communication

## Support & Documentation

- See [README.md](../../README.md) for project overview
- See role-specific READMEs in each role directory
- See [ROLES_IMPROVEMENT_OPPORTUNITIES.md](../../ROLES_IMPROVEMENT_OPPORTUNITIES.md) for architecture

## Author

Red Hat Management Team

## License

Apache-2.0
