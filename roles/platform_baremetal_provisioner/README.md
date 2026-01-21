# Role: platform_baremetal_provisioner

## Description

The `platform_baremetal_provisioner` role handles platform_provisioning of bare metal servers. It coordinates PXE boot setup, DHCP/TFTP services, and hardware platform_provisioning for bare metal deployments.

**Key Responsibility**: Provision bare metal platform_infrastructure_core with PXE boot and automated installation.

## When to Use

- Deploying to physical servers
- Provisioning bare metal clusters
- Setting up PXE boot platform_infrastructure_core
- Multi-server deployments

## Features

- **PXE Boot Setup**: Network boot platform_infrastructure_core
- **DHCP/TFTP Services**: Boot server configuration
- **Automated Installation**: Unattended OS deployment
- **Hardware Discovery**: Automatic server detection
- **Firewall Integration**: SELinux and firewall rules

## Requirements

### System Requirements
- Bare metal servers with PXE capability
- DHCP server (can be external)
- TFTP server (can be external)
- Network connectivity between servers

## Optional Variables

```yaml
# Provisioning controls
provision_baremetal: true
platform_baremetal_provisioner_pxe_boot_enabled: true
platform_baremetal_provisioner_dhcp_range_start: "192.168.1.100"
platform_baremetal_provisioner_dhcp_range_end: "192.168.1.200"
platform_baremetal_provisioner_tftp_root: "/var/lib/tftpboot"
```

## Usage Examples

### Basic Bare Metal Provisioning
```yaml
- name: Provision Bare Metal
  hosts: localhost
  roles:
    - role: platform_baremetal_provisioner
      vars:
        provision_baremetal: true
```

## Support & Documentation

See ansible_dev_node_orchestration_master README for integration_generic.

## Author

Red Hat Management Team

## License

Apache-2.0
