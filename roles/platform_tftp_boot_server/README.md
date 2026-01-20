# Role: platform_tftp_boot_server

## Description

The `platform_tftp_boot_server` role sets up TFTP boot services for PXE boot and network-based OS installation.

**Key Responsibility**: Configure TFTP boot services.

## When to Use

- Setting up PXE boot platform_infrastructure_core
- Network OS installation
- Bare metal platform_provisioning
- Boot server configuration

## Features

- **TFTP Service**: TFTP server setup
- **Boot Files**: Boot file management
- **PXE Configuration**: PXE boot setup
- **Boot Menu**: Boot menu configuration

## Requirements

- Network connectivity
- DHCP server
- Sufficient storage for boot images

## Usage Examples

```yaml
- name: Setup TFTP Boot Server
  hosts: bootstrap
  roles:
    - role: platform_tftp_boot_server
```

## Support & Documentation

See ansible_dev_node_orchestration_master README for integration_generic.

## Author

Red Hat Management Team

## License

Apache-2.0
