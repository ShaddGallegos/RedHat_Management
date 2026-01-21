# Role: ansible_dev_node_redhat_products/scenario_satellite

## Description

The `ansible_dev_node_redhat_products/scenario_satellite` role orchestrates the complete deployment of Red Hat Satellite 6.18. It coordinates content server setup, repository management, host platform_provisioning platform_infrastructure_core, and lifecycle management capabilities.

**Key Responsibility**: Deploy and configure Satellite 6.18 for systems management.

## When to Use

- Deploying Satellite in production environments
- Systems management and platform_provisioning platform_infrastructure_core
- Content distribution and repository management
- Host lifecycle management

## Features

- **Complete Satellite Stack**: Base server, API, content, hosts
- **Content Synchronization**: Automated repository sync
- **Host Provisioning**: PXE boot and host platform_provisioning
- **Lifecycle Management**: Update and patch management
- **API Integration**: Full REST API configuration
- **Reporting**: Comprehensive reporting and analytics

## Requirements

### System Requirements
- **CPU**: 8 cores minimum
- **Memory**: 32 GB minimum
- **Disk**: 500 GB minimum (content storage)
- **OS**: RHEL 9 or RHEL 10

### Network Requirements
- Ports: 80, 443, 5432, 5910-5930 (VNC)
- Upstream subscription connectivity
- Network access to managed hosts

## Required Variables

```yaml
deployment_scenario: "satellite_only"  # Satellite in scenario
```

## Optional Variables

```yaml
# Satellite controls
configure_satellite_api: true           # Enable API
configure_satellite_content: true       # Sync content
configure_satellite_hosts: true         # Configure host platform_provisioning
configure_satellite_postcfg: true       # Post-config tasks
deploy_satellite_reporting: true        # Deploy reporting

# Satellite configuration
satellite_version: "6.18"
satellite_hostname: "scenario_satellite.example.com"
satellite_admin_username: "admin"
satellite_admin_password: "{{ vault_satellite_pwd }}"

# Content synchronization
sync_initial_content: true
content_organizations: 
  - "Default Organization"
  - "Production"

# Host platform_provisioning
enable_host_provisioning: true
provisioning_network: "192.168.1.0/24"

# Reporting
enable_insights: true
```

## Usage Examples

### Basic Satellite Deployment
```yaml
- name: Deploy Satellite
  hosts: localhost
  roles:
    - role: ansible_dev_node_redhat_products/scenario_satellite
      vars:
        deployment_scenario: "satellite_only"
        satellite_admin_password: "{{ vault_satellite_pwd }}"
```

### Satellite with Full Integration
```yaml
- name: Deploy Satellite Full
  hosts: localhost
  roles:
    - role: ansible_dev_node_redhat_products/scenario_satellite
      vars:
        deployment_scenario: "satellite_only"
        configure_satellite_api: true
        configure_satellite_content: true
        enable_host_provisioning: true
        deploy_satellite_reporting: true
```

### Satellite for AAP Integration
```yaml
- name: Deploy Satellite + AAP
  hosts: localhost
  roles:
    - role: ansible_dev_node_redhat_products/scenario_satellite
      vars:
        deployment_scenario: "satellite_aap"
        sync_initial_content: true
```

## Deployment Flow

1. **Pre-Deployment Checks** - Verify disk space, network, subscriptions
2. **Deploy Base** - Core Satellite services
3. **Configure API** - REST API setup
4. **Sync Content** - Repository synchronization
5. **Configure Provisioning** - PXE boot and platform_provisioning
6. **Post Configuration** - Final setup
7. **Deploy Reporting** - Analytics and insights

## Supported Scenarios

- `satellite_only` - Satellite standalone
- `satellite_aap` - Satellite + AAP
- `satellite_idm` - Satellite + IdM
- `satellite_openshift` - Satellite + OpenShift
- All multi-product scenarios containing Satellite

## Output

- Satellite UI accessible at `https://{{ satellite_hostname }}`
- Content repositories synchronized
- Host platform_provisioning ready
- Reporting configured
- API endpoints functional

## Dependencies

| Role | Purpose |
|------|---------|
| ansible_dev_node_deployment_setup | Initialize environment |
| platform_infrastructure_manager | Provision platform_infrastructure_core |
| os_generic | Configure OS |
| integration_generic/satellite_* | Satellite integrations |

## Common Issues & Resolution

### Issue: "Insufficient disk space for content"
**Cause**: Less than 500GB available
**Resolution**: Expand disk or configure external storage

### Issue: "Content sync timeout"
**Cause**: Slow internet or large content
**Resolution**: Increase sync timeout or sync incrementally

### Issue: "Port 443 conflict"
**Cause**: Another service using HTTPS
**Resolution**: Change Satellite port or disable conflict

### Issue: "Subscription attach failure"
**Cause**: Invalid subscription or pool not available
**Resolution**: Verify subscription credentials and available pools

## Content Synchronization

Initial sync can take 2-4 hours depending on content size:

```yaml
# Recommended content
rhel9-baseos
rhel9-appstream
rhel9-supplementary
ansible-automation-platform-2.6
```

## Performance Tuning

```yaml
# For large deployments
satellite_content_workers: 8
satellite_pulp_workers: 8
satellite_db_pool_size: 100
sync_parallel_repositories: 4
```

## Security Considerations

- Store all passwords in Ansible vault
- Use HTTPS/TLS for all connections
- Implement network segmentation
- Regular backup of database and content
- Monitor audit logs
- Update Satellite regularly

## Monitoring & Troubleshooting

**Check Status**:
```bash
scenario_satellite-manage health-check
```

**View Sync Status**:
```bash
scenario_satellite-manage sync-status
```

**Database Backup**:
```bash
scenario_satellite-backup /backup/path
```

## Storage Considerations

- **Base Install**: 50GB
- **Content Storage**: 450GB+ (varies by products)
- **Database**: Grows with hosts
- **Backup**: 1.5x database size

## Support & Documentation

- Red Hat Satellite Documentation: https://access.redhat.com/documentation/scenario_satellite/
- See ansible_dev_node_orchestration_master README for integration_generic
- See integration_generic/satellite_* for product integrations

## Author

Red Hat Management Team

## License

Apache-2.0
