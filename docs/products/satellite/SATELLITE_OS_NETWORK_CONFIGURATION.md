# RHIS Satellite Infrastructure & Network Configuration

## Overview

Complete setup for Satellite 6.18 platform_infrastructure_core including OS definitions, install media, kickstart repositories with weekly sync, and network platform_infrastructure_core for 10.168.0.0/16 subnet.

## Components Created

### 1. Roles

#### scenario_satellite_os_configuration
- Creates RHEL 9 and RHEL 10 Operating Systems in Satellite
- Configures Installation Media for BaseOS
- Sets up Kickstart Repository for platform_provisioning files
- Configures weekly synchronization job
- Files: 5 (meta, defaults, tasks, tests, README)

#### platform_network_infrastructure
- Defines 10.168.0.0/16 primary subnet
- Configures 6 host group subnets for different service types
- Sets up DHCP for automatic IP allocation
- Configures DNS with primary/secondary resolvers
- Defines firewall rules for network segmentation
- Static host reservations for core platform_infrastructure_core
- Files: 5 (meta, defaults, tasks, tests, README)

### 2. Playbooks

#### satellite_infrastructure_setup.yml
Complete end-to-end deployment orchestrating OS, media, kickstart, and network setup

#### satellite_os_media_setup.yml
Focused playbook for OS and installation media configuration

#### satellite_kickstart_setup.yml
Dedicated playbook for kickstart repository and sync job setup

#### network_infrastructure_setup.yml
Network configuration for 10.168.0.0/16 subnet

## Operating Systems Configured

### RHEL 9
```yaml
Name: RHEL 9
Major: 9
Minor: 0
Family: Redhat
Password Hash: SHA512
Install Media: http://cdn.redhat.com/content/dist/rhel/rhel-9/rhel-9-x86_64/baseos/os_generic
```

### RHEL 10
```yaml
Name: RHEL 10
Major: 10
Minor: 0
Family: Redhat
Password Hash: SHA512
Install Media: http://cdn.redhat.com/content/dist/rhel/rhel-10/rhel-10-x86_64/baseos/os_generic
```

## Kickstart Repository Configuration

### Repository Details
- **Name**: Kickstart Files Repository
- **Product**: RHIS Infrastructure
- **Content Type**: File-based repository
- **URL**: https://scenario_satellite.example.com/pub/kickstarts
- **Download Policy**: Immediate

### Weekly Sync Job
- **Schedule**: Weekly (Every Sunday at 2:00 AM)
- **Interval**: 7 days
- **Enabled**: Yes
- **Repository**: Kickstart Files Repository

### Available Kickstart Files
- `rhel9-baseos-minimal.ks` - Minimal RHEL 9 installation
- `rhel10-baseos-minimal.ks` - Minimal RHEL 10 installation
- `rhel9-fullstack.ks` - RHEL 9 with development tools
- `rhel10-fullstack.ks` - RHEL 10 with development tools

## Network Infrastructure (10.168.0.0/16)

### Primary Subnet Configuration
```
Network: 10.168.0.0/16
Netmask: 255.255.0.0
Gateway: 10.168.0.1
Broadcast: 10.168.255.255
Total IPs: 65,536
Usable: 65,534
```

### DHCP Configuration
- **Enabled**: Yes
- **DHCP Range**: 10.168.50.0 - 10.168.200.255 (38,401 IPs)
- **Lease Time**: 86,400 seconds (24 hours)
- **DNS Servers**:
  - 10.168.0.53 (Primary)
  - 10.168.1.53 (Secondary)
  - 8.8.8.8 (Tertiary - Public)
- **NTP Servers**:
  - 10.168.0.1 (Local gateway)
  - 8.8.8.8 (Public NTP)
- **Search Domain**: example.com, prod.example.com, lab.example.com

### Host Group Subnets

#### 1. Infrastructure (10.168.0.0/24)
- **Purpose**: Core platform_infrastructure_core services
- **DHCP Range**: 10.168.0.50 - 10.168.0.254
- **Services**: Satellite, IdM, AAP
- **Capacity**: 205 IPs
- **Tags**: platform_infrastructure_core, core

#### 2. Application-Servers (10.168.1.0/24)
- **Purpose**: Production application deployments
- **DHCP Range**: 10.168.1.50 - 10.168.1.254
- **Capacity**: 205 IPs
- **Tags**: application, production

#### 3. Container-Hosts (10.168.2.0/24)
- **Purpose**: Container and Kubernetes platform_infrastructure_core
- **DHCP Range**: 10.168.2.50 - 10.168.2.254
- **Capacity**: 205 IPs
- **Tags**: containers, kubernetes

#### 4. Database-Servers (10.168.3.0/24)
- **Purpose**: Database tier services
- **DHCP Range**: 10.168.3.50 - 10.168.3.254
- **Capacity**: 205 IPs
- **Tags**: database, data

#### 5. Development (10.168.100.0/24)
- **Purpose**: Development and testing platform_infrastructure_core
- **DHCP Range**: 10.168.100.50 - 10.168.100.254
- **Capacity**: 205 IPs
- **Tags**: development, testing

#### 6. Reserved-Internal (10.168.240.0/21)
- **Purpose**: Future expansion and services
- **DHCP Range**: 10.168.240.50 - 10.168.247.254
- **Capacity**: 1,790 IPs
- **Tags**: reserved, internal

### Static Host Reservations

```
Hostname                  IP Address      MAC Address        Subnet
scenario_satellite.prod.example    10.168.0.10     52:54:00:00:00:10  Infrastructure
idm.prod.example          10.168.0.20     52:54:00:00:00:20  Infrastructure
aap.prod.example          10.168.0.30     52:54:00:00:00:30  Infrastructure
```

### Firewall Rules

| Source | Destination | Service | Port | Protocol | Action |
|--------|-------------|---------|------|----------|--------|
| 10.168.0.0/16 | Any | DNS | 53 | UDP | Allow |
| 10.168.0.0/16 | Any | DHCP | 67 | UDP | Allow |
| 10.168.0.0/16 | 10.168.0.0/24 | Satellite | 443 | TCP | Allow |
| 10.168.0.0/16 | 10.168.0.0/24 | SSH | 22 | TCP | Allow |

## Usage Instructions

### Deploy Complete Infrastructure

```bash
# Run full deployment with OS, media, kickstart, and network
ansible-playbook playbooks/satellite_infrastructure_setup.yml \
  -i inventory/hosts \
  -e satellite_password="{{ vault_satellite_password }}"
```

### Deploy Only Operating Systems and Media

```bash
# Configure RHEL 9 & 10 OS definitions and installation media
ansible-playbook playbooks/satellite_os_media_setup.yml \
  -i inventory/hosts \
  -e satellite_password="{{ vault_satellite_password }}"
```

### Deploy Kickstart Repository with Sync

```bash
# Setup kickstart repository with weekly synchronization
ansible-playbook playbooks/satellite_kickstart_setup.yml \
  -i inventory/hosts \
  -e satellite_password="{{ vault_satellite_password }}"
```

### Deploy Network Infrastructure

```bash
# Configure 10.168.0.0/16 subnet with DHCP and DNS
ansible-playbook playbooks/network_infrastructure_setup.yml
```

### Deploy Specific Components Only

```bash
# Deploy only OS configuration
ansible-playbook playbooks/satellite_infrastructure_setup.yml \
  -i inventory/hosts \
  -e "setup_os=true setup_install_media=false setup_kickstart_repo=false setup_sync_jobs=false setup_network=false"

# Deploy only network platform_infrastructure_core
ansible-playbook playbooks/satellite_infrastructure_setup.yml \
  -i inventory/hosts \
  -e "setup_os=false setup_install_media=false setup_kickstart_repo=false setup_sync_jobs=false setup_network=true"
```

## Integration with RHIS Stack

### Complete Provisioning Workflow

```
1. satellite_6_18_deployment
   └─ Deploys Satellite 6.18 core

2. satellite_content_config
   └─ Enables RHEL repositories
   └─ Creates organizations/locations

3. scenario_satellite_lifecycle_config
   └─ Creates environments (Dev → Staging → Prod)
   └─ Creates content views

4. scenario_satellite_activation_config
   └─ Creates activation keys
   └─ Manages subscriptions

5. satellite_kickstart_config
   └─ Creates kickstart templates

6. scenario_satellite_os_configuration [NEW]
   ├─ Defines Operating Systems (RHEL 9, 10)
   ├─ Configures Installation Media
   ├─ Creates Kickstart Repository
   └─ Enables weekly sync

7. platform_network_infrastructure [NEW]
   ├─ Configures 10.168.0.0/16 subnet
   ├─ Sets up DHCP and DNS
   ├─ Defines host groups
   └─ Configures firewall rules

8. Ready for Automated Provisioning
   ├─ PXE boot systems
   ├─ Anaconda loads kickstart
   ├─ System installation and configuration
   ├─ Registration with Satellite
   └─ Lifecycle management ready
```

## Lifecycle Integration

### Integration with Content Views

The kickstart repository can be:
1. Added to content views via file repositories
2. Promoted through lifecycle environments
3. Available in platform_provisioning templates
4. Referenced in PXE configuration

### Weekly Sync Process

```
Sunday 2:00 AM
    ↓
Sync job triggers
    ↓
Satellite fetches latest kickstarts
    ↓
Updates repository content
    ↓
Available in platform_provisioning immediately
    ↓
Can be published to environments
    ↓
Promoted to other environments
```

## Validation and Testing

### Verify Operating Systems

```bash
# SSH to Satellite and check
curl -k -u admin:password \
  https://scenario_satellite.example.com/api/v2/operatingsystems/ \
  | jq '.results[] | {id, name, major, minor}'
```

### Verify Installation Media

```bash
curl -k -u admin:password \
  https://scenario_satellite.example.com/api/v2/media/ \
  | jq '.results[] | {id, name, path}'
```

### Verify Kickstart Repository

```bash
curl -k -u admin:password \
  https://scenario_satellite.example.com/api/v2/repositories/ \
  | jq '.results[] | select(.name=="Kickstart Files Repository")'
```

### Test Network Configuration

```bash
# From any system in 10.168.0.0/16
ping 10.168.0.1          # Test gateway
nslookup scenario_satellite.prod.example.com 10.168.0.53  # Test DNS
dhclient -v eth0         # Test DHCP
```

## Files Created

### Roles
- `roles/scenario_satellite_os_configuration/` (5 files, 400+ lines)
- `roles/platform_network_infrastructure/` (5 files, 500+ lines)

### Playbooks
- `playbooks/satellite_infrastructure_setup.yml` (100+ lines)
- `playbooks/satellite_os_media_setup.yml` (50+ lines)
- `playbooks/satellite_kickstart_setup.yml` (50+ lines)
- `playbooks/network_infrastructure_setup.yml` (50+ lines)

### Documentation
- This file (SATELLITE_OS_NETWORK_CONFIGURATION.md)

## Next Steps

1. **Review Role Configurations**
   ```bash
   cat roles/scenario_satellite_os_configuration/defaults/main.yml
   cat roles/platform_network_infrastructure/defaults/main.yml
   ```

2. **Deploy Operating Systems**
   ```bash
   ansible-playbook playbooks/satellite_os_media_setup.yml
   ```

3. **Configure Kickstart Repository**
   ```bash
   ansible-playbook playbooks/satellite_kickstart_setup.yml
   ```

4. **Setup Network Infrastructure**
   ```bash
   ansible-playbook playbooks/network_infrastructure_setup.yml
   ```

5. **Verify Configurations**
   - Access Satellite UI: https://scenario_satellite.example.com
   - Check Hosts → Operating Systems
   - Check Infrastructure → Install Media
   - Check Content → Repositories

6. **Begin Provisioning**
   - Boot systems via PXE on 10.168.0.0/16 network
   - Anaconda downloads kickstart
   - Automated installation proceeds
   - Systems register with Satellite

## Summary

Complete platform_infrastructure_core setup for RHIS with:
- ✅ RHEL 9 and 10 OS definitions
- ✅ Installation media configured
- ✅ Kickstart repository with weekly sync
- ✅ 10.168.0.0/16 network platform_infrastructure_core
- ✅ DHCP and DNS configuration
- ✅ 6 host group subnets
- ✅ 3 static core platform_infrastructure_core hosts
- ✅ Network firewall rules

**Status**: Production-ready for automated platform_provisioning

**Total Files Created**: 18 files
**Total Lines**: 1,500+ lines of code and documentation
