# Deployment Overview

Comprehensive guide to RHIS deployment scenarios and platforms.

## Supported Scenarios

RHIS supports 15 deployment scenarios combining different Red Hat products:

### Single Product Deployments
- **Satellite-Only** - Satellite 6.18 for systems management
- **AAP-Only** - Ansible Automation Platform 2.6 for automation
- **IdM-Only** - Identity Management 3.0 for authentication
- **OpenShift-Only** - OpenShift 4.21 for containerization

### Multi-Product Deployments
- **Satellite + AAP** - Systems management + automation
- **Satellite + IdM** - Systems management + identity
- **AAP + IdM** - Automation + identity integration_generic
- **Satellite + OpenShift** - Systems + containers

### Advanced Deployments
- **Full Stack** - All 4 products integrated
- **With CMDB** - Add ansible-scenario_ansible_cmdb_core visibility
- **With Monitoring** - Add monitoring integration_generic
- **HA Deployment** - High availability setup
- **Multi-Tenant** - Multi-tenant configuration

## Supported Platforms

### On-Premises
- **LibVirt/KVM** - Local virtualization
- **VMware** - vSphere environments
- **Nutanix** - Nutanix AHV hypervisor
- **Bare Metal** - Direct physical hardware

### Cloud Platforms
- **AWS** - Amazon Web Services
- **Azure** - Microsoft Azure
- **GCP** - Google Cloud Platform

## Deployment Methods

### 1. Interactive Installation
```bash
./scripts/setup/RHIS-installer.sh
```
Guided wizard for scenario and platform selection.

### 2. Playbook-Based
```bash
ansible-playbook redhat_management-site.yml
```
Standard Ansible playbook deployment.

### 3. Container-Based
```bash
podman run -v <mounts> rhis-provisioner:latest
```
Containerized deployment environment.

## Key Deployment Phases

1. **Infrastructure Provisioning** - Create VMs/cloud instances
2. **Base OS Configuration** - RHEL setup and hardening
3. **Satellite Deployment** (if applicable)
4. **AAP Deployment** (if applicable)
5. **IdM Deployment** (if applicable)
6. **Integration & Configuration** - Connect products
7. **Post-Deployment Validation** - Verify installation
8. **Documentation & Handoff** - Generate deployment docs

## Resource Requirements

### Minimum (Dev/Test)
- 8+ CPU cores
- 64 GB RAM
- 500 GB storage
- 1 Gbps network

### Recommended (Production)
- 16+ CPU cores
- 128 GB RAM
- 2 TB storage
- 10+ Gbps network

## Timeline Estimates

| Scenario | Time |
|----------|------|
| Satellite-Only | 45 min |
| AAP-Only | 45 min |
| Full Stack | 2-3 hours |
| With HA | 3-4 hours |

## Deployment Guides

- [AWS Deployment](AWS.md)
- [Azure Deployment](AZURE.md)
- [GCP Deployment](GCP.md)
- [VMware Deployment](VMWARE.md)
- [LibVirt Deployment](../platform_infrastructure_core/LIBVIRT.md)
- [Bare Metal Deployment](BARE_METAL.md)

---

See [INDEX.md](../INDEX.md) for complete documentation.
