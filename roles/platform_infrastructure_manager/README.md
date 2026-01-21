# Role: platform_infrastructure_manager

## Description

The `platform_infrastructure_manager` role orchestrates platform-specific platform_infrastructure_core platform_provisioning and preparation. It acts as the routing layer between the ansible_dev_node_orchestration engine and platform-specific provisioners (LibVirt, Bare Metal, AWS, Azure, GCP, VMware, Nutanix).

**Key Responsibility**: Prepare and validate platform_infrastructure_core for deployment.

## When to Use

- Provisioning cloud platform_infrastructure_core
- Preparing bare metal servers
- Setting up virtual environments
- Multi-platform deployments

## Features

- **Multi-Platform Support**: 7 different platform_infrastructure_core platforms
- **Dynamic Task Routing**: Automatically selects correct platform
- **Pre-Deployment Validation**: Verifies prerequisites before platform_provisioning
- **Installation Method Support**: OEM driver and TFTP boot methods
- **Error Handling**: Comprehensive error detection and recovery

## Requirements

### Platform-Specific Requirements

**LibVirt**: KVM host with libvirt-daemon, virt-manager  
**Bare Metal**: DHCP server, TFTP server, PXE boot loader  
**AWS**: AWS CLI, valid credentials, EC2 permissions  
**Azure**: Azure CLI, valid credentials, VM creation permissions  
**GCP**: Google Cloud SDK, valid credentials, Compute Engine permissions  
**VMware**: VMware vCenter access, VM creation permissions  
**Nutanix**: Nutanix Prism access, VM creation permissions  

## Required Variables

```yaml
deployment_platform: "libvirt"  # Required: Platform type
```

## Optional Variables

```yaml
# Infrastructure controls
platform_infrastructure_manager_deploy_infrastructure: true
infrastructure_timeout: 1800

# Platform-specific
libvirt_network: "default"
baremetal_dhcp_range: "192.168.1.100-200"
aws_region: "us-east-1"
azure_resource_group: "rhis-rg"
gcp_project: "my-project"
vmware_datacenter: "DC1"
nutanix_cluster: "cluster-1"
```

## Usage Examples

### LibVirt Provisioning
```yaml
- name: Prepare LibVirt Infrastructure
  hosts: localhost
  roles:
    - role: platform_infrastructure_manager
      vars:
        deployment_platform: "libvirt"
        libvirt_network: "default"
```

### AWS Provisioning
```yaml
- name: Prepare AWS Infrastructure
  hosts: localhost
  roles:
    - role: platform_infrastructure_manager
      vars:
        deployment_platform: "aws"
        aws_region: "us-east-1"
```

### Bare Metal Provisioning
```yaml
- name: Prepare Bare Metal
  hosts: localhost
  roles:
    - role: platform_infrastructure_manager
      vars:
        deployment_platform: "baremetal"
        install_method: "tftp"
```

## Supported Platforms

| Platform | Support Level | Install Methods |
|----------|---------------|-----------------|
| LibVirt | Full | OEMDRV, TFTP |
| Bare Metal | Full | OEMDRV, TFTP |
| AWS | Full | Cloud API |
| Azure | Full | Cloud API |
| GCP | Full | Cloud API |
| VMware | Full | vCenter API |
| Nutanix | Full | Prism API |

## Dependencies

None (platform provisioners are called dynamically)

## Outputs

- Validated platform_infrastructure_core ready for deployment
- Network connectivity confirmed
- Provisioning services operational

## Common Issues & Resolution

### Issue: "LibVirt daemon is not running"
```bash
# Resolution
sudo systemctl start libvirtd
```

### Issue: "DHCP/TFTP not running"
```bash
# Resolution
sudo systemctl start dhcpd
sudo systemctl start tftp
```

### Issue: "AWS credentials not configured"
```bash
# Resolution
aws configure
# or set environment variables
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
```

## Performance

- LibVirt preparation: < 5 minutes
- Bare Metal preparation: < 5 minutes
- AWS preparation: 5-10 minutes
- Azure preparation: 5-10 minutes
- GCP preparation: 5-10 minutes
- VMware preparation: < 5 minutes
- Nutanix preparation: < 5 minutes

## Security Considerations

- Requires platform-specific credentials
- Store credentials in Ansible vault
- Limit network access to platform_infrastructure_core endpoints
- Enable encryption for cloud credentials

## Support & Documentation

- See ansible_dev_node_orchestration_master README for integration_generic details
- See platform-specific documentation in prepare_*.yml tasks

## Author

Red Hat Management Team

## License

Apache-2.0
