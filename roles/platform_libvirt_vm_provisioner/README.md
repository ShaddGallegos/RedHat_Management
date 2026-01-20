# Libvirt VM Provisioner Role

Automated RHEL 10 virtual machine platform_provisioning on Libvirt using Ansible.

## Overview

This role automates the complete process of creating and configuring RHEL 10 virtual machines on Libvirt platform_infrastructure_core. It handles:

- Prerequisites validation (ISO, kickstart, libvirt)
- HTTP server setup for kickstart delivery
- VM creation with `virt-install`
- Installation monitoring
- VM verification and connection info
- Automated cleanup

## Features

✅ **Fully Automated** - Zero manual intervention after setup
✅ **Idempotent** - Can be run multiple times safely
✅ **Customizable** - All aspects configurable via variables
✅ **Monitored** - Real-time installation progress tracking
✅ **Error Handling** - Comprehensive validation and error messages
✅ **Production Ready** - Security hardening included

## Requirements

### System Requirements

- Libvirt daemon installed and running
- `virt-install` utility
- `python3` with HTTP server ansible_dev_node_support
- Ansible 2.10+

### Files Required

1. **RHEL 10 ISO** - Place in path specified by `libvirt_iso_file`
2. **Kickstart File** - Place in path specified by `libvirt_kickstart_file`

### Permissions

This role requires `become: yes` for some tasks. Ensure your Ansible user can use sudo without password.

## Role Variables

### Essential Variables

```yaml
libvirt_vm_name: "rhel10-vm"           # VM name
libvirt_vm_cpus: 2                      # vCPU count
libvirt_vm_memory: 2048                 # RAM in MB
libvirt_vm_disk: 50                     # Disk size in GB
libvirt_iso_file: "files/rhel-10.iso"  # ISO file path
libvirt_kickstart_file: "files/oem.cfg" # Kickstart file path
libvirt_vm_network: "default"           # Libvirt network
```

### Optional Network Variables

```yaml
libvirt_bridge_device: null             # Bridge device (optional)
libvirt_mac_address: null               # MAC address (optional)
libvirt_static_ip: null                 # Static IP (optional)
libvirt_gateway: null                   # Gateway (optional)
libvirt_nameserver: null                # Nameserver (optional)
```

### Kickstart Variables

```yaml
libvirt_root_password: "..."            # Root password hash (CHANGE THIS!)
libvirt_ansible_user: "ansible"         # Ansible user to create
libvirt_install_ansible: true           # Install Ansible user
libvirt_packages:                        # Packages to install
  - "@core"
  - "@standard"
  - "vim"
  - "python3"
```

### Security Variables

```yaml
libvirt_enable_selinux: true            # Enable SELinux
libvirt_enable_firewall: true           # Enable firewall
libvirt_firewall_services:              # Allowed services
  - "ssh"
```

### HTTP Server Variables

```yaml
libvirt_kickstart_port: 8888            # HTTP server port
libvirt_kickstart_http_dir: "/tmp/..."  # HTTP directory
```

### Monitoring Variables

```yaml
libvirt_monitor_timeout: 300            # Timeout in seconds
libvirt_monitor_interval: 5             # Check interval
```

### Logging Variables

```yaml
libvirt_save_logs: true                 # Save logs
libvirt_logs_dir: "/tmp/libvirt-..."    # Log directory
libvirt_log_level: "info"               # Log level
```

### Cleanup Variables

```yaml
libvirt_cleanup_http_server: true       # Cleanup HTTP server
libvirt_cleanup_temp_files: true        # Cleanup temp files
```

See [defaults/main.yml](defaults/main.yml) for complete list.

## Usage Examples

### Basic Usage

```yaml
---
- name: Provision RHEL 10 VM
  hosts: localhost
  gather_facts: yes
  roles:
    - platform_libvirt_vm_provisioner
```

### Custom Configuration

```yaml
---
- name: Provision Production VM
  hosts: localhost
  gather_facts: yes
  roles:
    - role: platform_libvirt_vm_provisioner
      vars:
        libvirt_vm_name: "prod-web-01"
        libvirt_vm_cpus: 8
        libvirt_vm_memory: 16384
        libvirt_vm_disk: 200
        libvirt_static_ip: "192.168.1.100"
        libvirt_gateway: "192.168.1.1"
        libvirt_nameserver: "8.8.8.8"
```

### Via Include

```yaml
---
- name: Create multiple VMs
  hosts: localhost
  gather_facts: yes
  tasks:
    - name: Provision VM 1
      include_role:
        name: platform_libvirt_vm_provisioner
      vars:
        libvirt_vm_name: "app-server-01"
        libvirt_vm_cpus: 4
        libvirt_vm_memory: 8192

    - name: Provision VM 2
      include_role:
        name: platform_libvirt_vm_provisioner
      vars:
        libvirt_vm_name: "app-server-02"
        libvirt_vm_cpus: 4
        libvirt_vm_memory: 8192
```

### With Custom Inventory

```yaml
---
- name: Provision VM and add to inventory
  hosts: localhost
  gather_facts: yes
  tasks:
    - name: Create VM
      include_role:
        name: platform_libvirt_vm_provisioner
      vars:
        libvirt_vm_name: "new-host"
        libvirt_vm_cpus: 4
        libvirt_vm_memory: 8192

    - name: Add to inventory
      add_host:
        name: "{{ libvirt_vm_ip }}"
        groups: rhel10_vms
        ansible_user: root
```

## Role Structure

```
platform_libvirt_vm_provisioner/
├── tasks/
│   ├── main.yml              # Main entry point
│   ├── validate.yml          # Prerequisite validation
│   ├── logging.yml           # Logging setup
│   ├── http_server.yml       # HTTP server for kickstart
│   ├── create_vm.yml         # VM creation
│   ├── monitor.yml           # Installation monitoring
│   ├── verify.yml            # VM verification
│   ├── display_info.yml      # Display connection info
│   └── cleanup.yml           # Cleanup
├── handlers/
│   └── main.yml              # Event handlers
├── templates/
│   └── kickstart.j2          # Jinja2 kickstart template
├── files/                    # Static files (if needed)
├── defaults/
│   └── main.yml              # Default variables
├── vars/
│   └── main.yml              # Role variables
└── README.md                 # This file
```

## Task Flow

1. **Display Configuration** - Show all settings
2. **Validate Prerequisites** - Check files and system
3. **Setup Logging** - Initialize log files
4. **Setup Kickstart Delivery** - Start HTTP server
5. **Create Virtual Machine** - Run virt-install
6. **Monitor Installation** - Wait for completion
7. **Verify VM Creation** - Confirm VM is ready
8. **Display VM Information** - Show connection details
9. **Cleanup** - Stop HTTP server and remove temp files

## Variables Used in Role

### Facts Set by Role

```yaml
libvirt_local_ip              # Local IP for HTTP server
libvirt_http_server_pid       # PID of HTTP server
libvirt_kickstart_url         # URL to kickstart file
libvirt_vm_created            # Boolean: VM created
libvirt_installation_complete # Boolean: Installation done
libvirt_provisioning_success  # Boolean: Success
libvirt_vm_ip                 # VM's IP address
```

## Customizing Kickstart

The role uses a Jinja2 template for the kickstart file at [templates/kickstart.j2](templates/kickstart.j2).

### Add Packages

```yaml
libvirt_packages:
  - "@core"
  - "@standard"
  - "vim"
  - "git"
  - "python3"
  - "docker"
```

### Change Root Password

Generate a hash:
```bash
echo 'YourPassword' | openssl passwd -stdin -crypt
```

Then:
```yaml
libvirt_root_password: "$1$salt$YourHashHere"
```

### Configure Static Networking

```yaml
libvirt_static_ip: "192.168.1.100"
libvirt_gateway: "192.168.1.1"
libvirt_nameserver: "8.8.8.8"
```

### Customize Post-Installation

Edit [templates/kickstart.j2](templates/kickstart.j2) to add custom tasks in the `%post` section.

## Troubleshooting

### ISO File Not Found

```
ERROR: stat module failed: file does not exist: files/rhel-10.iso
```

**Solution:**
```bash
ls -lh files/rhel-10.iso
# Download RHEL 10 ISO to files/
```

### Kickstart File Not Found

```
ERROR: stat module failed: file does not exist: files/oem.cfg
```

**Solution:**
```bash
cp roles/platform_libvirt_vm_provisioner/templates/kickstart.j2 files/oem.cfg
```

### Libvirtd Not Running

```
FAILED! => {"failed": true, "msg": "Failed to start libvirtd"}
```

**Solution:**
```bash
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
```

### VM Already Exists

```
FAILED! => {"msg": "VM 'rhel10-vm' already exists"}
```

**Solution:**
```bash
virsh undefine rhel10-vm --remove-all-storage
# Or use different VM name
```

### Network Not Found

```
FAILED! => {"rc": 1, "msg": "Network validation failed"}
```

**Solution:**
```bash
virsh net-list
# Create network if missing
sudo virsh net-define /etc/libvirt/qemu/networks/default.xml
sudo virsh net-start default
```

## Integration with Other Roles

### Add to Inventory After Creation

```yaml
- name: Provision VM and add to inventory
  hosts: localhost
  gather_facts: yes
  roles:
    - platform_libvirt_vm_provisioner
  
  post_tasks:
    - name: Add VM to inventory
      add_host:
        name: "{{ libvirt_vm_name }}"
        ansible_host: "{{ libvirt_vm_ip }}"
        ansible_user: root
        groups: rhel10_vms
```

### Chain Multiple Roles

```yaml
---
- name: Provision and Configure VM
  hosts: localhost
  gather_facts: yes
  
  tasks:
    - name: Provision VM
      include_role:
        name: platform_libvirt_vm_provisioner
      vars:
        libvirt_vm_name: "app-server"
    
    - name: Configure VM
      include_role:
        name: app_server_setup
      vars:
        target_host: "{{ libvirt_vm_name }}"
```

## Performance Tuning

### VM-Level Tuning

Add to post-installation script in [templates/kickstart.j2](templates/kickstart.j2):

```bash
# CPU performance
echo "vm.sched_migration_cost_ns = 5000000" >> /etc/sysctl.conf

# Network tuning
echo "net.core.rmem_max = 134217728" >> /etc/sysctl.conf
echo "net.core.wmem_max = 134217728" >> /etc/sysctl.conf

sysctl -p
```

## Security Considerations

1. **Change Default Root Password** - Edit root password hash before use
2. **SSH Keys** - Configure SSH keys for ansible user in post-install
3. **Firewall** - Review and adjust firewall rules for your use case
4. **SELinux** - Enable SELinux for production environments
5. **Network Isolation** - Use appropriate Libvirt networks for security

## License

Same as the parent RHIS project

## Support

For issues or questions:
1. Check [defaults/main.yml](defaults/main.yml) for all available options
2. Review task files in [tasks/](tasks/) directory
3. Check Ansible logs: `ansible-playbook -vv`
4. View VM console: `virsh console <vm-name>`
5. Check Libvirt logs: `journalctl -u libvirtd`
