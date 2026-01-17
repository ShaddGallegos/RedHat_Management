<!-- markdownlint-disable MD013 -->
# Role: satellite_kickstart_config

## Description

The `satellite_kickstart_config` role configures Satellite 6.18 provisioning templates and kickstart files for automated RHEL 9 and RHEL 10 BaseOS installations with optional AppStream integration.

**Key Responsibility**: Configure RHEL 9 and RHEL 10 kickstart templates for Satellite provisioning.

## When to Use

- Setting up Satellite provisioning infrastructure
- Creating automated installation templates
- Configuring RHEL 9 and RHEL 10 installations
- Enabling network-based provisioning via PXE
- Deploying infrastructure with Satellite

## Features

- **RHEL 9 BaseOS Minimal Kickstart**: Minimal RHEL 9 installation with Satellite integration
- **RHEL 10 BaseOS Minimal Kickstart**: Minimal RHEL 10 installation with Satellite integration
- **RHEL 9 Full Stack Kickstart**: RHEL 9 with development tools and container support
- **RHEL 10 Full Stack Kickstart**: RHEL 10 with development tools and container support
- **LVM Partitioning**: Compliance-ready partition schemes
- **Security Hardening**: SSH hardening, SELinux, firewall configuration
- **Satellite Integration**: Subscription manager and Insights integration
- **Cloud-Init Support**: Cloud provisioning capabilities
- **Container Runtime**: Podman, Buildah, Skopeo for container deployments

## Required Variables

```yaml
satellite_url: "https://satellite.example.com"
satellite_username: "admin"
satellite_password: "{{ vault_satellite_admin_pwd }}"
```

## Optional Variables

```yaml
satellite_organization: "Default Organization"
create_provisioning_templates: true
upload_kickstart_files: true
kickstart_files_path: "/var/lib/foreman/public/kickstarts"
kickstart_web_url: "{{ satellite_url }}/pub/kickstarts"
```

## Kickstart Templates Provided

### 1. RHEL 9 BaseOS Minimal

```yaml
kickstart_templates:
  - name: "RHEL 9 BaseOS Kickstart (Minimal)"
    description: "RHEL 9 BaseOS minimal installation template for RHIS"
    os: "RHEL 9"
    template_type: "provision"
```

**Includes**:
- Core packages only
- LVM disk partitioning
- SSH security hardening
- Satellite subscription manager
- Insights client integration
- Cloud-init support

**Use Case**: Minimal server deployments

### 2. RHEL 10 BaseOS Minimal

```yaml
kickstart_templates:
  - name: "RHEL 10 BaseOS Kickstart (Minimal)"
    description: "RHEL 10 BaseOS minimal installation template for RHIS"
    os: "RHEL 10"
    template_type: "provision"
```

**Use Case**: Minimal RHEL 10 deployments

### 3. RHEL 9 Full Stack

**Includes**:
- All BaseOS packages
- Development tools (gcc, make, kernel-devel)
- Container management (Podman, Buildah, Skopeo)
- Ansible and automation tools
- Network tools and debugging utilities
- Extended storage for containers

**Use Case**: Application servers, container hosts

### 4. RHEL 10 Full Stack

**Includes**:
- All BaseOS + AppStream packages
- Development tools suite
- Modern container runtime (Podman v4+)
- Ansible automation
- Extended system tools

**Use Case**: Production application servers, container infrastructure

## Kickstart File Contents

All kickstarts include:

### Localization
- Language: en_US.UTF-8
- Timezone: UTC
- Keyboard: us

### Security
- SELinux: enforcing
- Firewall: enabled with SSH service
- SSH key generation
- Root password: locked
- User account: rhis (locked by default)

### Disk Configuration

**Partitioning Scheme**:
```
/boot              1024 MB (ext4)
/boot/efi          256 MB (EFI)
/                  10 GB (XFS, LVM)
/home              2 GB (XFS, LVM)
/tmp               2 GB (XFS, LVM)
/var               5-8 GB (XFS, LVM)
/var/log           2 GB (XFS, LVM)
/var/log/audit     1 GB (XFS, LVM)
/var/lib/containers 5 GB (XFS, LVM) [Full Stack only]
swap               4 GB
```

**Volume Group**: vg_rhel
**Filesystem**: XFS with LVM logical volumes

### Network Configuration
- DHCP-based network configuration
- Network Manager enabled
- IPv4 only (IPv6 disabled)
- Hostname: localhost.localdomain (DHCP assigned)

### Services Configuration

**Enabled Services**:
- NetworkManager
- sshd (SSH server)
- chronyd (time synchronization)
- podman [Full Stack]
- crond (cron daemon) [Full Stack]

**Disabled Services**:
- cups (printing)
- postfix (mail)
- avahi-daemon (mDNS)
- ntp (replaced by chronyd)
- bluez (Bluetooth)

### Package Sets

**Minimal Kickstarts**:
- @core (Core package group)
- @base (Base packages)
- @container-management (Container basics)
- Essential utilities (git, curl, wget, tmux, vim)
- Subscription manager
- Insights client

**Full Stack Kickstarts**:
- All minimal packages
- @development-tools (gcc, make, etc.)
- @system-tools (advanced administration)
- @network-tools (debugging and monitoring)
- Development headers (kernel, python3, systemd)
- Container tools (Podman, Buildah, Skopeo)
- Ansible and ansible-runner
- Network utilities (bind-utils, tcpdump, telnet)

## Usage

### Using Kickstarts with Satellite PXE Boot

1. **Access Satellite Web UI**:
   ```
   https://satellite.example.com
   ```

2. **Navigate to Hosts → Provisioning Templates**:
   - View available templates
   - Templates will use the kickstart files created

3. **Create Provisioning Host**:
   - Set Operating System: RHEL 9 or RHEL 10
   - Select Template: Choose appropriate template (Minimal or Full Stack)
   - Configure Network: Use DHCP or static IP
   - Set Activation Key: Select for subscription management

4. **Boot via PXE**:
   - System boots from network
   - Anaconda installer loads kickstart from Satellite
   - Automated installation proceeds
   - System registers with Satellite via activation key

### Default Configuration

```yaml
- name: Configure Satellite Kickstarts
  hosts: satellite
  roles:
    - role: satellite_kickstart_config
      vars:
        create_provisioning_templates: true
        upload_kickstart_files: true
        satellite_organization: "Default Organization"
```

### Disable Kickstart File Upload

```yaml
- role: satellite_kickstart_config
  vars:
    upload_kickstart_files: false
    # Only create template metadata
```

## Kickstart File Locations

### On Satellite Server

```
/var/lib/foreman/public/kickstarts/rhel9-baseos-minimal.ks
/var/lib/foreman/public/kickstarts/rhel10-baseos-minimal.ks
/var/lib/foreman/public/kickstarts/rhel9-fullstack.ks
/var/lib/foreman/public/kickstarts/rhel10-fullstack.ks
```

### Web Accessible URLs

```
https://satellite.example.com/pub/kickstarts/rhel9-baseos-minimal.ks
https://satellite.example.com/pub/kickstarts/rhel10-baseos-minimal.ks
https://satellite.example.com/pub/kickstarts/rhel9-fullstack.ks
https://satellite.example.com/pub/kickstarts/rhel10-fullstack.ks
```

## Integration with RHIS Stack

### Complete Provisioning Workflow

```
1. satellite_6_18_deployment
   └─ Deploys Satellite 6.18 core
   
2. satellite_content_config
   └─ Enables RHEL BaseOS/AppStream repositories
   
3. satellite_lifecycle_config
   └─ Creates content views and environments
   
4. satellite_activation_config
   └─ Creates activation keys for subscription management
   
5. satellite_kickstart_config [THIS ROLE]
   ├─ Creates RHEL 9/10 kickstart templates
   ├─ Stores kickstart files for PXE boot
   └─ Enables automated provisioning
   
6. System Provisioning
   ├─ Boot via PXE
   ├─ Load kickstart from Satellite
   ├─ Automated installation
   ├─ Register with activation key
   └─ Ready for management
```

## Kickstart Customization

### Modify Disk Partitioning

Edit `defaults/main.yml` and adjust partition sizes:

```yaml
rhel9_baseos_minimal_ks: |
  # Change swap size to 8 GB
  logvol swap --vgname=vg_rhel --size=8192 --name=lv_swap
  
  # Change root size to 20 GB
  logvol / --vgname=vg_rhel --size=20480 --name=lv_root --fstype=xfs
```

### Add Additional Packages

Modify the `%packages` section:

```yaml
%packages
@core
@base
@container-management

# Add your packages here
gcc-gfortran
postgresql
nginx
%end
```

### Modify Post-Installation Scripts

Update `%post` sections to add custom configuration:

```yaml
%post
# Your custom post-install commands
echo "Custom configuration here"
%end
```

## Output

- Kickstart files created and stored
- Templates registered with Satellite
- Kickstart URLs available for PXE boot
- Summary of provisioning options
- Status of all four kickstart templates

## Security Considerations

- All kickstarts enforce SELinux
- SSH hardening configured
- Firewall enabled by default
- Root password locked (must set via Satellite)
- User accounts locked initially
- Cloud-init for post-provision configuration

## Dependencies

- redhat.satellite collection (optional, for template management)
- Satellite 6.18 deployed and running
- Foreman/Pulp web server accessible

## Author

Red Hat Management Team

## License

Apache-2.0

## See Also

- [satellite_content_config](../satellite_content_config/README.md) - Content management
- [satellite_lifecycle_config](../satellite_lifecycle_config/README.md) - Content views and environments
- [satellite_activation_config](../satellite_activation_config/README.md) - Activation keys and subscriptions
- [Red Hat Kickstart Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/performing_an_automated_installation_using_kickstart/kickstart-intro_kickstart)
- [Satellite Provisioning Guide](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.18/html/provisioning_guide/)
