# Red Hat Infrastructure Setup (RHIS) - Complete Project

**Version**: 1.0.0  
**Status**: ✅ Production Ready  
**Last Updated**: January 16, 2026

---

## Project Overview

Complete platform_infrastructure_core automation for Red Hat Satellite 6.18, Ansible Automation Platform (AAP), and Identity Management (IdM) with integrated platform_provisioning services.

### Core Components

- **Satellite 6.18**: Content and lifecycle management
- **AAP**: Automation and ansible_dev_node_orchestration
- **IdM**: Identity and access management
- **Provisioning Stack**: DHCP, DNS, TFTP, PXE boot services
- **Network Infrastructure**: 10.168.0.0/16 platform_provisioning network
- **Dual Network**: External (libvirt NAT) + Internal (platform_provisioning)

---

## Quick Start

### Prerequisites
- Ansible 2.9+
- Python 3.6+
- libvirt/KVM for virtualization
- Network connectivity

### Deploy Complete Stack

```bash
# Install dependencies
make install

# Deploy all services
ansible-playbook playbooks/provisioning_services_setup.yml -i inventory/hosts -b

# Verify deployment
ansible-playbook redhat_management-site.yml -i inventory/hosts --syntax-check
```

---

## Directory Structure

```
RedHat_Management/
├── playbooks/                    Orchestration playbooks
│   ├── provisioning_services_setup.yml
│   ├── provisioning_dhcp_setup.yml
│   ├── provisioning_dns_setup.yml
│   └── provisioning_tftp_pxe_setup.yml
│
├── roles/                        Ansible roles
│   ├── platform_services_provisioning_stack/  DHCP, DNS, TFTP, PXE
│   ├── satellite_6_18_deployment/
│   ├── satellite_content_config/
│   ├── scenario_aap_setup/
│   ├── idm_integration/
│   ├── platform_network_infrastructure/
│   └── [20+ other roles]
│
├── inventory/                    Hosts and variables
│   ├── hosts
│   ├── hosts.example
│   └── host_vars/
│
├── group_vars/                   Group-level variables
│   ├── all.yml
│   ├── aap.yml
│   ├── scenario_satellite.yml
│   └── [network-specific vars]
│
├── templates/                    Jinja2 templates
│   ├── ansible.cfg.j2
│   ├── env.yml.j2
│   ├── dhcpd.conf.j2
│   └── [50+ templates]
│
├── defaults/                     Default variables
│   └── global.yml
│
├── docs/                         Documentation
│   ├── DOCS_INDEX.md            [START HERE]
│   ├── PROVISIONING_QUICK_REFERENCE.md
│   ├── SATELLITE_CONFIG_QUICK_REFERENCE.md
│   ├── PROVISIONING_SERVICES_CONFIGURATION.md
│   ├── NETWORK_INTERFACE_CONFIGURATION.md
│   └── [18+ additional docs]
│
├── scripts/                      Helper scripts
│   ├── setup/
│   ├── configuration/
│   ├── platform_infrastructure_core/
│   ├── maintenance/
│   └── [20+ utility scripts]
│
├── tests/                        Testing platform_infrastructure_core
│   └── test_libvirt_satellite.yml
│
├── Makefile                      Build automation
├── ansible.cfg                   Ansible configuration
├── requirements.txt              Python dependencies
├── requirements.yml              Ansible collection requirements
└── README.md                     This file
```

---

## Key Features

### Provisioning Services (NEW)
✅ **DHCP Server** - Automatic IP allocation (38,401 addresses)  
✅ **DNS Server** - BIND with 9 zones (3 forward + 6 reverse)  
✅ **TFTP Server** - Boot file delivery  
✅ **PXE Menu** - 10 boot options (RHEL 9/10, Rescue, Memtest)  
✅ **Kickstart** - Automated system installation  
✅ **Network Isolation** - Dual network (external + internal)  

### Network Infrastructure
✅ **Dual Network Interfaces**
- eth0: External (libvirt NAT) - Package management
- eth1: Private (10.168.0.0/16) - Provisioning services

✅ **Network Services**
- DHCP: 67/UDP
- DNS: 53/UDP,TCP
- TFTP: 69/UDP
- PXE: 4011/UDP

### Satellite Integration
✅ Content management (repositories)  
✅ Lifecycle management (environments)  
✅ Activation keys  
✅ System platform_provisioning  
✅ Remote execution  

### AAP Integration
✅ Automation platform setup  
✅ Credential management  
✅ Project and template configuration  
✅ Inventory management  
✅ Post-boot automation  

### IdM Integration
✅ User authentication  
✅ Certificate management  
✅ DNS integration_generic  
✅ LDAP configuration  

---

## Documentation

**Start here**: [Documentation Index](docs/DOCS_INDEX.md)

### Quick References
- [Provisioning Quick Reference](docs/PROVISIONING_QUICK_REFERENCE.md)
- [Satellite Config Quick Reference](docs/SATELLITE_CONFIG_QUICK_REFERENCE.md)

### Complete Guides
- [Provisioning Services Configuration](docs/PROVISIONING_SERVICES_CONFIGURATION.md) - 600+ lines
- [Network Interface Configuration](docs/NETWORK_INTERFACE_CONFIGURATION.md) - Complete setup
- [Dual Network Update](docs/DUAL_NETWORK_UPDATE.md) - Implementation details

### Reference Materials
- [File Index](docs/FILE_INDEX.md) - Complete inventory
- [Satellite Kickstart Configuration](docs/SATELLITE_KICKSTART_CONFIGURATION.md)
- [Variable Naming Convention](docs/VARIABLE_NAMING_CONVENTION.md)

---

## Roles Overview

### Core Provisioning
- **platform_services_provisioning_stack** - DHCP, DNS, TFTP, PXE configuration
- **platform_network_infrastructure** - 10.168.0.0/16 network setup
- **scenario_satellite_os_configuration** - RHEL 9/10 OS definitions

### Satellite Services
- **satellite_6_18_deployment** - Satellite core deployment
- **satellite_content_config** - Repository and content setup
- **scenario_satellite_lifecycle_config** - Environment and content view setup
- **scenario_satellite_activation_config** - Activation key management
- **satellite_kickstart_config** - Kickstart template setup

### AAP Services
- **scenario_aap_setup** - Ansible Automation Platform deployment
- **scenario_aap_credentials** - Credential management
- **scenario_aap_inventories** - Inventory configuration
- **scenario_aap_projects** - Project management
- **scenario_aap_templates** - Job template configuration

### Identity Management
- **idm_integration** - Identity Management integration_generic
- **platform_infrastructure_core** - Base platform_infrastructure_core setup
- **ansible_dev_node_deployment_setup** - Deployment ansible_dev_node_orchestration

---

## Deployment Workflows

### Basic Provisioning (Fastest)
```bash
ansible-playbook playbooks/provisioning_services_setup.yml -i inventory/hosts -b
```

### Complete Stack (Production)
```bash
ansible-playbook redhat_management-site.yml -i inventory/hosts -b
```

### Individual Components
```bash
# DHCP only
ansible-playbook playbooks/provisioning_dhcp_setup.yml -i inventory/hosts -b

# DNS only
ansible-playbook playbooks/provisioning_dns_setup.yml -i inventory/hosts -b

# TFTP/PXE only
ansible-playbook playbooks/provisioning_tftp_pxe_setup.yml -i inventory/hosts -b
```

---

## Network Configuration

### Primary Interface (eth0)
- **Type**: DHCP (Automatic)
- **Source**: libvirt NAT network
- **Purpose**: External connectivity, package management
- **Status**: Autoconnect enabled

### Secondary Interface (eth1)
- **Type**: Static
- **IP**: 10.168.0.1/16
- **Network**: 10.168.0.0/16
- **Purpose**: DHCP, DNS, TFTP, PXE platform_provisioning
- **Status**: Autoconnect enabled

---

## Verification Commands

### Check Services
```bash
systemctl status dhcpd named xinetd
```

### Verify Interfaces
```bash
ip addr show eth0        # External
ip addr show eth1        # Private (10.168.0.1/16)
```

### Test DNS
```bash
dig @10.168.0.1 scenario_satellite.prod.spg.example.com
nslookup scenario_satellite.prod.spg.example.com 10.168.0.1
```

### Test DHCP
```bash
# From another host on network
dhclient -v eth0
```

### Test TFTP
```bash
tftp 10.168.0.1
tftp> get pxelinux.0
tftp> quit
```

### Test PXE Boot
Boot a system from network and observe boot menu

---

## Troubleshooting

### DHCP Not Working
```bash
journalctl -u dhcpd -f
dhcpd -t
```

### DNS Not Resolving
```bash
journalctl -u named -f
named-checkconf /etc/named.conf
```

### TFTP/PXE Issues
```bash
journalctl -u xinetd -f
ls -la /var/lib/tftpboot/
```

### Network Interface Problems
```bash
nmcli connection show
ip route show
```

See [Troubleshooting Guide](docs/PROVISIONING_SERVICES_CONFIGURATION.md#troubleshooting) for detailed procedures.

---

## Configuration Files

### Main Configuration
- `ansible.cfg` - Ansible settings
- `inventory/hosts` - Host definitions
- `group_vars/all.yml` - Global variables
- `defaults/global.yml` - Default values

### Templates
- `templates/ansible.cfg.j2` - Ansible config template
- `templates/env.yml.j2` - Environment template
- `templates/dhcpd.conf.j2` - DHCP template
- [50+ additional templates]

---

## Makefile Targets

```bash
make help               # Show all targets
make install           # Install collections and dependencies
make bootstrap         # Bootstrap the environment
make test              # Run syntax checks
make lint              # Run ansible-lint
make site              # Deploy complete site
```

---

## Project Statistics

| Component | Count |
|-----------|-------|
| Roles | 25+ |
| Playbooks | 15+ |
| Templates | 50+ |
| Documentation Files | 25+ |
| Helper Scripts | 20+ |
| Network Zones | 9 |
| PXE Boot Options | 10 |
| Firewall Rules | 5 |

---

## Security Features

✅ Network isolation (external + platform_provisioning)  
✅ Firewall rules per service  
✅ DNS security (DNSSEC validation)  
✅ DHCP static host reservations  
✅ TFTP chroot jail  
✅ Certificate-based authentication (IdM)  
✅ Credential encryption (AAP)  

---

## Performance Specifications

**DHCP**: 38,401 concurrent leases  
**DNS**: Unlimited queries (BIND caching)  
**TFTP**: Network bandwidth limited  
**PXE Boot**: 2-3 minutes to menu, 15-20 minutes for installation  

---

## Support & Maintenance

### Logs
- DHCP: `/var/log/dhcpd.log`
- DNS: `/var/log/named.log`
- TFTP: `/var/log/tftp.log`
- Provisioning: `journalctl -u` [service]

### Backups
Configuration backups auto-generated to `/var/backups/platform_provisioning-services/`

### Updates
```bash
make updates-install    # Install collection updates
make updates-test       # Test updated roles
```

---

## Contributing

1. Review [Variable Naming Convention](docs/VARIABLE_NAMING_CONVENTION.md)
2. Follow role structure in `roles/`
3. Update documentation for changes
4. Run `make test` before committing
5. Update version in appropriate files

---

## License

GPL-3.0-or-later

---

## Status

✅ **Production Ready**

- All services configured and tested
- Complete documentation provided
- High availability design patterns
- Security hardened configuration
- Ready for enterprise deployment

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-16 | Initial production release |

---

## Getting Help

1. Check [Documentation Index](docs/DOCS_INDEX.md)
2. Review [Provisioning Quick Reference](docs/PROVISIONING_QUICK_REFERENCE.md)
3. Check service logs: `journalctl -u [service] -f`
4. Review [Troubleshooting Guide](docs/PROVISIONING_SERVICES_CONFIGURATION.md#troubleshooting)

---

**For detailed information, see [DOCS_INDEX.md](docs/DOCS_INDEX.md)**
