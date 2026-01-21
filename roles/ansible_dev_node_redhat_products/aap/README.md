# Role: ansible_dev_node_redhat_products/aap

## Description

The `ansible_dev_node_redhat_products/aap` role orchestrates the complete deployment of Ansible Automation Platform (AAP) 2.6+. It coordinates the deployment of all AAP components including controllers, execution environments, event-driven automation, and role-based access control.

**Key Responsibility**: Deploy and configure AAP 2.6+ for enterprise automation.

## When to Use

- Deploying AAP in production environments
- Setting up automation platform_infrastructure_core
- Integrating AAP with other products
- Enterprise automation platforms

## Features

- **Complete AAP Stack**: Base, RBAC, callbacks, EDA
- **High Availability**: Support for multiple controllers
- **Execution Environments**: Custom execution environment deployment
- **Event Driven Automation**: Deploy EDA capabilities
- **RBAC Configuration**: Role-based access control setup
- **Comprehensive Validation**: Post-deployment health checks

## Requirements

### System Requirements
- **CPU**: 8 cores minimum
- **Memory**: 16 GB minimum
- **Disk**: 100 GB minimum
- **OS**: RHEL 9 or RHEL 10

### Network Requirements
- Ports: 80, 443, 5432, 27017, 6379
- DNS resolution for AAP hostname
- Network access to container registries

## Required Variables

```yaml
deployment_scenario: "aap_only"  # AAP must be in scenario
```

## Optional Variables

```yaml
# AAP controls
configure_aap_rbac: true                   # Setup RBAC
configure_aap_callbacks: true              # Setup callbacks
deploy_aap_eda: true                       # Deploy Event Driven Automation
aap_version: "2.6"                         # AAP version
aap_hostname: "aap.example.com"            # FQDN
aap_admin_password: "{{ vault_aap_pwd }}"  # Admin password (use vault!)

# High Availability
aap_ha_enabled: false
aap_controller_replicas: 1

# Execution Environments
create_custom_ee: false
ee_registry: "registry.redhat.io"

# Performance tuning
aap_max_jobs: 100
aap_task_timeout: 3600
aap_db_pool_size: 50
```

## Usage Examples

### Basic AAP Deployment
```yaml
- name: Deploy AAP
  hosts: localhost
  roles:
    - role: ansible_dev_node_redhat_products/aap
      vars:
        deployment_scenario: "aap_only"
        aap_admin_password: "{{ vault_aap_admin_pwd }}"
```

### AAP with RBAC and EDA
```yaml
- name: Deploy AAP Full
  hosts: localhost
  roles:
    - role: ansible_dev_node_redhat_products/aap
      vars:
        deployment_scenario: "aap_only"
        configure_aap_rbac: true
        deploy_aap_eda: true
        aap_hostname: "aap.prod.spg"
```

### AAP with Custom Execution Environment
```yaml
- name: Deploy AAP Custom
  hosts: localhost
  roles:
    - role: ansible_dev_node_redhat_products/aap
      vars:
        deployment_scenario: "satellite_aap"
        create_custom_ee: true
        ee_registry: "registry.example.com"
```

## Deployment Flow

1. **Validate Configuration** - Check prerequisites and requirements
2. **Deploy Base Components** - Core AAP services
3. **Configure RBAC** - Role and permission setup
4. **Deploy Callbacks** - Callback webhooks
5. **Deploy EDA** - Event-driven automation
6. **Health Validation** - Verify all components

## Supported Scenarios

- `aap_only` - AAP standalone
- `satellite_aap` - Satellite + AAP
- `aap_idm` - AAP + IdM
- `aap_openshift` - AAP + OpenShift
- `satellite_aap_idm` - 3-product combo
- `satellite_aap_openshift` - 3-product combo
- `aap_idm_openshift` - 3-product combo
- `satellite_aap_idm_openshift` - All 4 products

## Output

- AAP controller accessible at `https://{{ aap_hostname }}`
- Admin user configured
- RBAC roles created
- Execution environments available
- Health check passed

## Dependencies

| Role | Purpose |
|------|---------|
| ansible_dev_node_deployment_setup | Initialize environment |
| platform_infrastructure_manager | Provision platform_infrastructure_core |
| os_generic | Configure OS |
| integration_generic/* | Product integrations |

## Common Issues & Resolution

### Issue: "Insufficient disk space"
**Cause**: Less than 100GB available
**Resolution**: Expand disk or provision on different storage

### Issue: "Port 443 already in use"
**Cause**: Another service using HTTPS port
**Resolution**: Change AAP port or stop conflicting service

### Issue: "Database connection failed"
**Cause**: PostgreSQL not running
**Resolution**: Verify database service is running

### Issue: "RBAC configuration failed"
**Cause**: Invalid user/group configuration
**Resolution**: Verify LDAP/IdM integration_generic settings

## Performance Tuning

```yaml
# For high-load environments
aap_max_jobs: 500
aap_db_pool_size: 100
aap_cache_ttl: 3600
aap_task_workers: 4
```

## Security Considerations

- Store all passwords in Ansible vault
- Use HTTPS/TLS for all connections
- Implement strong RBAC policies
- Regular backup of database
- Monitor audit logs
- Update AAP regularly

## Monitoring & Troubleshooting

**Check Status**:
```bash
ansible-ctl status
```

**View Logs**:
```bash
tail -f /var/log/aap/controller.log
```

**Health Check**:
```bash
ansible-ctl health-check
```

## Support & Documentation

- Red Hat AAP Documentation: https://docs.ansible.com/automation-platform/
- See ansible_dev_node_orchestration_master README for integration_generic
- See integration_generic/* for product integrations

## Author

Red Hat Management Team

## License

Apache-2.0
