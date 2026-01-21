# Role: ansible_dev_node_support

## Description

The `ansible_dev_node_support` role orchestrates post-deployment validation, testing, and ansible_dev_node_support tasks. It performs preflight checks, runs test suites, manages backups, and provides deployment diagnostics.

**Key Responsibility**: Validate deployment and provide ongoing ansible_dev_node_support capabilities.

## When to Use

- Post-deployment validation
- Running deployment tests
- Backup and recovery operations
- Troubleshooting deployments
- Health monitoring

## Features

- **Preflight Checks**: Pre-deployment validation
- **Testing Framework**: Comprehensive testing
- **Backup/Restore**: Data protection
- **Diagnostics**: Troubleshooting tools
- **Reporting**: Test results and reports
- **Configuration Database**: Inventory tracking

## Requirements

### System Requirements
- Storage for backups (500GB+ recommended)
- Test environment or staging
- Access to all deployed products

## Optional Variables

```yaml
# Validation controls
run_preflight_checks: true
run_tests: false
backup_and_restore: false
configure_cmdb: true

# Test types
test_types:
  - connectivity
  - services
  - api
  - integration_generic

# Backup settings
backup_destination: "/backup"
backup_retention_days: 30
backup_schedule: "daily"  # daily, weekly, monthly

# CMDB settings
cmdb_enabled: true
cmdb_update_frequency: 86400  # seconds
```

## Usage Examples

### Run Preflight Checks
```yaml
- name: Validate Deployment
  hosts: localhost
  roles:
    - role: ansible_dev_node_support
      vars:
        run_preflight_checks: true
```

### Run Complete Tests
```yaml
- name: Test Deployment
  hosts: localhost
  roles:
    - role: ansible_dev_node_support
      vars:
        run_tests: true
        test_types:
          - connectivity
          - services
          - api
```

### Setup Backup
```yaml
- name: Configure Backup
  hosts: localhost
  roles:
    - role: ansible_dev_node_support
      vars:
        backup_and_restore: true
        backup_destination: "/mnt/backup"
```

## Preflight Checks

Validates:
- System resources (CPU, memory, disk)
- Network connectivity
- Required services running
- Port availability
- Firewall rules
- DNS resolution
- Subscription status

## Test Suite

### Connectivity Tests
- Network ping tests
- Service port accessibility
- DNS resolution

### Service Tests
- Service availability
- Service health checks
- Port listening verification

### API Tests
- API endpoint availability
- Authentication verification
- Basic API operations

### Integration Tests
- Product communication
- Data synchronization
- Credential validation

## Backup & Recovery

### Backup Operations
```bash
# Create backup
ansible-playbook backup.yml

# Verify backup
ansible-playbook verify_backup.yml

# List backups
ls -la /backup/rhis
```

### Recovery Operations
```bash
# Restore from backup
ansible-playbook restore.yml --extra-vars backup_file=rhis-20260116.tar.gz
```

## CMDB (Configuration Management Database)

Tracks:
- Deployed hosts
- Product configurations
- Integration settings
- Change history
- Asset inventory

## Common Issues & Resolution

### Issue: "Insufficient disk space for backup"
**Cause**: Not enough storage
**Resolution**: Increase backup storage or reduce retention

### Issue: "API connectivity test failed"
**Cause**: API endpoint unavailable
**Resolution**: Verify product is running and accessible

### Issue: "Service health check failed"
**Cause**: Service not running
**Resolution**: Restart service and investigate logs

### Issue: "CMDB update failed"
**Cause**: Database connectivity issue
**Resolution**: Verify database is running

## Monitoring & Health Checks

**Check Overall Health**:
```bash
ansible-playbook roles/ansible_dev_node_support/tasks/health_check.yml
```

**View Test Results**:
```bash
cat /var/log/deployment-tests.log
```

**Generate Report**:
```bash
ansible-playbook roles/ansible_dev_node_support/tasks/deployment_report.yml
```

## Best Practices

1. **Always run preflight checks** before deployment
2. **Create backups** regularly
3. **Test recovery procedures** periodically
4. **Monitor CMDB** for changes
5. **Archive test results** for audit trail
6. **Document failures** for troubleshooting
7. **Update baselines** as needed

## Performance

- Preflight checks: 2-5 minutes
- Full test suite: 5-10 minutes
- Backup (initial): 30-60 minutes
- Backup (incremental): 5-10 minutes
- CMDB update: 1-2 minutes

## Storage Requirements

- Backup: 1.5x database size
- Log files: 500MB - 2GB
- CMDB database: 100MB - 500MB
- Test reports: 50MB - 200MB

## Security Considerations

- Encrypt backups
- Restrict backup access
- Secure CMDB database
- Audit backup operations
- Test recovery regularly
- Document procedures
- Maintain backup copies offline

## Support & Documentation

- See ansible_dev_node_orchestration_master README for ansible_dev_node_orchestration
- See troubleshooting guides in docs/
- See integration_generic/* for integration_generic-specific tests

## Author

Red Hat Management Team

## License

Apache-2.0
