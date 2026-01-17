# Services Provisioning Stack Role

Comprehensive Ansible role for configuring dual network interfaces and all provisioning services (DHCP, DNS, PXE, TFTP).

## Overview

This role deploys and configures all provisioning services on `satellite.prod.spg` server with dual network connectivity:

- **eth0**: External network (libvirt NAT) - DHCP auto IP
- **eth1**: Private network (10.168.0.0/16) - Static 10.168.0.1
- **DHCP Server**: Automatic IP allocation for 10.168.0.0/16 network
- **DNS Server**: BIND DNS with zones for example.com and prod.example.com
- **TFTP Server**: Boot file delivery for PXE clients
- **PXE Boot**: Network boot menu with RHEL 9 and 10 options
- **Resolv.conf**: Configured with 10.168.0.1 nameserver and rotate option

## Features

✅ Primary ethernet interface configuration (eth0 - external/libvirt NAT)  
✅ Secondary ethernet interface configuration (eth1 - private provisioning)  
✅ DHCP with static host reservations  
✅ BIND DNS with forward and reverse zones  
✅ TFTP with PXE menu configuration  
✅ Resolv.conf with nameserver 10.168.0.1  
✅ Options rotate for DNS query load balancing  
✅ Firewall rules for all services  
✅ Service validation and health checks  
✅ Dual network isolation and independence  

## Network Architecture

```
┌─────────────────────────────────────────┐
│   satellite.prod.spg                    │
├──────────────────┬──────────────────────┤
│  eth0            │  eth1                │
│  External        │  Private             │
│  libvirt NAT     │  10.168.0.0/16       │
│  DHCP (auto)     │  10.168.0.1 (static) │
│  Package mgmt    │  DHCP/DNS/TFTP/PXE   │
└──────────────────┴──────────────────────┘
```

## Service Details

### Primary Interface: eth0 (External - libvirt NAT)
- **Type**: DHCP (Automatic)
- **IP Source**: libvirt NAT network
- **Purpose**: External connectivity, package management
- **Autoconnect**: Enabled
- **Services**: System updates, package management

### Secondary Interface: eth1 (Private - Provisioning)
- **Type**: Static
- **IP**: 10.168.0.1/16
- **Network**: 10.168.0.0/16
- **Gateway**: 10.168.0.1
- **Autoconnect**: Enabled
- **Services**: DHCP, DNS, TFTP, PXE

### DHCP
- **Interface**: eth1 (10.168.0.1)
- **Range**: 10.168.50.0 - 10.168.200.255
- **Nameservers**: 10.168.0.1, 10.168.1.53, 8.8.8.8
- **Static Hosts**: satellite (10.168.0.10), idm (10.168.0.20), aap (10.168.0.30)

### DNS
- **Zones**: example.com, prod.example.com
- **Nameserver**: 10.168.0.1:53
- **Forward Resolution**: A and CNAME records
- **Reverse Resolution**: PTR zones for 10.168.0.0/16

### Resolv.conf
- **Nameserver**: 10.168.0.1
- **Search Domains**: example.com, prod.example.com, lab.example.com
- **Options**: rotate, timeout:2, attempts:3

### TFTP/PXE
- **Root**: /var/lib/tftpboot
- **Bootloader**: pxelinux.0
- **Menu**: PXE menu with RHEL 9/10 options
- **Kickstart Repo**: http://10.168.0.1/kickstarts

## Variables

See `defaults/main.yml` for all configuration variables including:
- Primary interface settings (eth0 - external)
- Secondary interface settings (eth1 - private)
- DHCP range and lease times
- DNS zone files
- Firewall port configurations

## Usage

```yaml
---
- name: Deploy Provisioning Services
  hosts: satellite
  gather_facts: true
  roles:
    - role: services_provisioning_stack
      vars:
        provisioning_host: "satellite.prod.spg"
        provisioning_primary_interface: "eth0"
        provisioning_secondary_interface: "eth1"
        provisioning_interface_ip: "10.168.0.1"
        dhcp_enabled: true
        dns_enabled: true
        tftp_enabled: true
```

## Files Created

### Network Configuration
- `eth0` connection (external NAT)
- `eth1` connection (private provisioning)

### Service Configuration
- `/etc/dhcp/dhcpd.conf` - DHCP configuration
- `/etc/named.conf` - DNS configuration
- `/var/lib/tftpboot/` - TFTP root directory
- `/var/lib/tftpboot/pxelinux.cfg/default` - PXE boot menu
- `/etc/resolv.conf` - DNS resolver configuration

## Firewall Rules

| Service | Port | Protocol |
|---------|------|----------|
| DHCP | 67 | UDP |
| DHCP Client | 68 | UDP |
| DNS | 53 | UDP/TCP |
| TFTP | 69 | UDP |
| PXE | 4011 | UDP |

## Validation

The role includes validation tasks that verify:
- Primary interface (eth0) is UP and has external IP
- Secondary interface (eth1) is UP with IP 10.168.0.1
- DHCP service is running on eth1
- DNS service is running on eth1
- TFTP (xinetd) is running on eth1
- DNS resolution works
- Firewall rules are applied
- Resolv.conf is correctly configured

## Network Isolation Benefits

- **Security**: Provisioning network isolated from external traffic
- **Performance**: No contention between provisioning and external traffic
- **Reliability**: Provisioning available even if external network fails
- **Flexibility**: Independent network management per interface
- **Scalability**: Each network scales independently
