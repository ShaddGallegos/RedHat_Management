# Site.yml Quick Reference Guide

## Overview

The `site.yml` playbook orchestrates the complete Red Hat Satellite 6.17 deployment by running all roles in the proper order with dependencies.

## Execution Order

1. **satellite_build** - Core Satellite installation and configuration
2. **satellite_pxe_services** - PXE, DHCP, TFTP, LibVirt setup
3. **satellite_content** - Repository and content view management
4. **satellite_provisioning** - Node provisioning workflows

## Basic Usage

### Complete Deployment
```bash
ansible-playbook -i inventory site.yml
```

### Verbose Output
```bash
ansible-playbook -i inventory site.yml -vvv
```

### Check Mode (Dry Run)
```bash
ansible-playbook -i inventory site.yml --check
```

## Phase-Based Execution

### Run Specific Phases
```bash
# Phase 1 only (Core installation)
ansible-playbook -i inventory site.yml --tags phase1

# Phase 1 & 2 only (Core + PXE)
ansible-playbook -i inventory site.yml --tags phase1,phase2

# Phase 3 only (Content management)
ansible-playbook -i inventory site.yml --tags phase3

# Phase 4 only (Provisioning)
ansible-playbook -i inventory site.yml --tags phase4
```

### Run Specific Roles
```bash
# Core installation only
ansible-playbook -i inventory site.yml --tags satellite_build

# PXE services only
ansible-playbook -i inventory site.yml --tags satellite_pxe_services

# Content management only
ansible-playbook -i inventory site.yml --tags satellite_content

# Provisioning workflows only
ansible-playbook -i inventory site.yml --tags satellite_provisioning
```

## Role Control Variables

Control which roles run by setting variables in `group_vars/all.yml`:

```yaml
# Enable/disable specific roles
satellite_build_enabled: true
satellite_pxe_enabled: true
satellite_content_enabled: true
satellite_provisioning_enabled: true
```

### Skip Specific Roles
```bash
# Skip PXE services
ansible-playbook -i inventory site.yml -e "satellite_pxe_enabled=false"

# Skip provisioning
ansible-playbook -i inventory site.yml -e "satellite_provisioning_enabled=false"
```

## Advanced Options

### Limit to Specific Hosts
```bash
ansible-playbook -i inventory site.yml --limit satellite.prod.spg
```

### Continue on Errors
```bash
ansible-playbook -i inventory site.yml --force-handlers
```

### Start from Specific Task
```bash
ansible-playbook -i inventory site.yml --start-at-task "Configure Satellite repositories"
```

## Output and Monitoring

### Real-time Output
The playbook provides comprehensive output including:
- Pre-deployment system validation
- Phase-by-phase progress updates
- Service status verification
- Post-deployment summary
- Access credentials and next steps

### Generated Reports
After completion, check:
- `/root/satellite_deployment_summary.md` - Detailed deployment report
- `/var/log/ansible/` - Ansible execution logs
- `/var/log/foreman/` - Satellite application logs

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure you're running as root or with sudo
2. **Network Issues**: Verify firewall rules and network connectivity
3. **Package Conflicts**: Roles handle foreman-maintain locks automatically
4. **Service Failures**: Check systemd status and logs

### Debug Mode
```bash
ansible-playbook -i inventory site.yml -vvv --step
```

### Skip Failing Tasks
```bash
ansible-playbook -i inventory site.yml --skip-tags problematic_tag
```

## Prerequisites

Before running site.yml:
1. Update `inventory` with correct Satellite server details
2. Configure vault variables in `group_vars/all.yml`
3. Ensure target system meets minimum requirements
4. Verify Red Hat subscription is active

## Post-Deployment

After successful execution:
1. Access Web UI at `https://your-satellite-server`
2. Login with configured admin credentials
3. Verify all services are running
4. Test node provisioning capabilities
5. Review deployment summary report

---

**Note**: The site.yml playbook is designed for production use with comprehensive error handling, validation, and reporting.
