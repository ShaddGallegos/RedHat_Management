# Role: os_generic

## Description

The `os_generic` role handles operating system configuration including package installation, system settings, firewall configuration, and security hardening.

**Key Responsibility**: Configure operating system for Red Hat platform_infrastructure_core.

## When to Use

- OS-level configuration
- System hardening
- Package installation
- Network configuration

## Features

- **Package Management**: Install required packages
- **System Configuration**: Configure system settings
- **Firewall Management**: Configure firewall rules
- **Security Hardening**: Apply security policies
- **Network Configuration**: Configure network interfaces

## Requirements

- RHEL 9 or RHEL 10
- Root access
- Network connectivity

## Usage Examples

```yaml
- name: Configure OS
  hosts: all
  roles:
    - role: os_generic
      vars:
        configure_firewall: true
        enable_selinux: true
```

## Support & Documentation

See ansible_dev_node_orchestration_master README for integration_generic.

## Author

Red Hat Management Team

## License

Apache-2.0
