# Role: baremetal_provisioner

## Description

The `baremetal_provisioner` role handles provisioning of bare metal servers. It coordinates PXE boot setup, DHCP/TFTP services, and hardware provisioning for bare metal deployments.

**Key Responsibility**: Provision bare metal infrastructure with PXE boot and automated installation.

## When to Use

- Deploying to physical servers
- Provisioning bare metal clusters
- Setting up PXE boot infrastructure
- Multi-server deployments

## Features

- **PXE Boot Setup**: Network boot infrastructure
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
pxe_boot_enabled: true
dhcp_range_start: "192.168.1.100"
dhcp_range_end: "192.168.1.200"
tftp_root: "/var/lib/tftpboot"
```

## Usage Examples

### Basic Bare Metal Provisioning
```yaml
- name: Provision Bare Metal
  hosts: localhost
  roles:
    - role: baremetal_provisioner
      vars:
        provision_baremetal: true
```

## Support & Documentation

See orchestration_master README for integration.

## Author

Red Hat Management Team

## License

Apache-2.0
