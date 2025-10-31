# Red Hat Satellite Upgrade Checklist

This checklist provides a comprehensive guide for upgrading Red Hat Satellite using the maintenance and remediation tool.

## Pre-Upgrade Planning

### Version Compatibility Matrix
| Current Version | Supported Upgrade Path | RHEL Support |
|----------------|----------------------|--------------|
| 6.15.x | 6.16.x | RHEL 8, 9 |
| 6.16.x | 6.17.x | RHEL 8, 9 |
| 6.17.x | 6.18.x (when available) | RHEL 9 |

### Pre-Upgrade Requirements Checklist

#### System Prerequisites
- [ ] Current Satellite version identified and documented
- [ ] Target version selected (one y-stream only)
- [ ] RHEL version compatibility verified
- [ ] Red Hat subscriptions current and valid
- [ ] Maintenance window scheduled (4-6 hours recommended)

#### Documentation Review
- [ ] Red Hat Satellite upgrade documentation reviewed
- [ ] Release notes for target version reviewed
- [ ] Known issues and workarounds documented
- [ ] Customer Portal upgrade helper consulted

#### Backup and Recovery
- [ ] Full system backup completed and verified
- [ ] Database backup validated
- [ ] Configuration export completed
- [ ] System snapshot created (if virtualized)
- [ ] Recovery procedures tested and documented

#### Environment Preparation
- [ ] All content synchronization jobs completed
- [ ] Content view publications up to date
- [ ] No active provisioning or configuration management jobs
- [ ] System load below normal operating thresholds
- [ ] Disk space verified (minimum 20% free recommended)

## Upgrade Execution Checklist

### Phase 1: System Preparation
- [ ] Stop all non-essential Satellite operations
- [ ] Verify system health using foreman-maintain
- [ ] Create Red Hat support case proactively
- [ ] Notify stakeholders of maintenance start

### Phase 2: Repository Configuration
- [ ] Disable all current repositories
- [ ] Enable target version repositories
- [ ] Verify repository accessibility
- [ ] Update repository metadata

### Phase 3: Package Updates
- [ ] Unlock foreman packages
- [ ] Update satellite-installer package
- [ ] Update foreman-maintain package
- [ ] Install yum-utils if not present
- [ ] Build package dependencies

### Phase 4: Upgrade Execution
- [ ] Execute foreman-maintain upgrade run
- [ ] Monitor upgrade progress and logs
- [ ] Address any prompted questions
- [ ] Verify upgrade completion

### Phase 5: Post-Upgrade Validation
- [ ] Update all packages
- [ ] Restart all services
- [ ] Verify web interface accessibility
- [ ] Test API functionality
- [ ] Validate database integrity
- [ ] Check content synchronization
- [ ] Verify host management functions

## Detailed Upgrade Commands

### Repository Management (RHEL 9)
```bash
# Disable all repositories
sudo subscription-manager repos --disable="*"

# Enable RHEL 9 base repositories
sudo subscription-manager repos \
  --enable=rhel-9-for-x86_64-baseos-rpms \
  --enable=rhel-9-for-x86_64-appstream-rpms

# Enable Satellite 6.17 repositories (example)
sudo subscription-manager repos \
  --enable=satellite-utils-6.17-for-rhel-9-x86_64-rpms \
  --enable=satellite-maintenance-6.17-for-rhel-9-x86_64-rpms \
  --enable=satellite-6.17-for-rhel-9-x86_64-rpms
```

### Core Package Updates
```bash
# Unlock packages
sudo foreman-maintain packages unlock

# Update core packages
sudo dnf upgrade -y satellite-installer foreman-maintain

# Install utilities
sudo dnf install -y yum-utils

# Build dependencies
sudo yum-builddep -y satellite-installer foreman-maintain \
  --skip-broken --allowerasing --best
```

### Upgrade Execution
```bash
# Execute upgrade to target version
sudo foreman-maintain upgrade run --target-version 6.17

# Update all packages post-upgrade
sudo foreman-maintain packages update -y
```

## Validation Procedures

### Service Status Verification
```bash
# Check all services
foreman-maintain service status

# Verify specific service functionality
systemctl status httpd
systemctl status postgresql
systemctl status pulpcore-api
systemctl status foreman
```

### Functional Testing
```bash
# Test web interface
curl -k https://$(hostname)/users/login

# Test API
hammer --version
hammer ping

# Test content management
hammer repository list
hammer content-view list

# Test host management
hammer host list --per-page 5
```

### Database Integrity
```bash
# Check database connectivity
foreman-maintain health check --label database-connection

# Verify schema version
su - postgres -c "psql foreman -c 'SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 5;'"

# Check for database issues
foreman-rake db:migrate:status
```

## Rollback Procedures

### When to Consider Rollback
- Upgrade fails with unrecoverable errors
- Critical services cannot be restored
- Data corruption is detected
- Business-critical functions are impaired

### Rollback Steps
1. **Immediate Actions:**
   ```bash
   # Stop all services
   foreman-maintain service stop
   
   # Restore from backup
   satellite-maintain restore /path/to/backup/
   
   # Start services
   foreman-maintain service start
   ```

2. **Validation:**
   - Verify all services start successfully
   - Test critical business functions
   - Validate data integrity
   - Confirm rollback success

3. **Post-Rollback:**
   - Document rollback reason
   - Update Red Hat support case
   - Plan remediation strategy
   - Schedule new upgrade attempt

## Capsule Server Considerations

### Upgrade Sequence
1. **Satellite Server First:** Always upgrade Satellite before Capsules
2. **Version Tolerance:** Capsules can run one version behind temporarily
3. **Capsule Upgrade:** Plan separate maintenance windows for each Capsule

### Capsule Upgrade Checklist
- [ ] Satellite server upgrade completed and validated
- [ ] Capsule upgrade packages available
- [ ] Capsule-specific backup completed
- [ ] Content synchronization with Satellite verified

## Common Issues and Solutions

### Repository Access Issues
**Problem:** Cannot access new version repositories
**Solution:**
```bash
# Check subscription status
subscription-manager status

# Refresh subscriptions
subscription-manager refresh

# Re-enable repositories
subscription-manager repos --enable=satellite-6.17-for-rhel-9-x86_64-rpms
```

### Package Dependency Conflicts
**Problem:** Dependency resolution failures during upgrade
**Solution:**
```bash
# Clear package cache
dnf clean all

# Update package metadata
dnf makecache

# Retry with specific options
dnf upgrade --skip-broken --allowerasing --best
```

### Service Start Failures
**Problem:** Services fail to start after upgrade
**Solution:**
```bash
# Check specific service logs
journalctl -u foreman -n 50

# Reset failed services
systemctl reset-failed

# Restart services individually
foreman-maintain service restart --only foreman
```

### Database Migration Issues
**Problem:** Database schema migration failures
**Solution:**
```bash
# Check migration status
foreman-rake db:migrate:status

# Run specific migration
foreman-rake db:migrate RAILS_ENV=production

# Reset database connections
foreman-maintain service restart --only postgresql
```

## Post-Upgrade Tasks

### Immediate Tasks (Day 1)
- [ ] Monitor system performance and logs
- [ ] Verify all critical business functions
- [ ] Update monitoring and alerting systems
- [ ] Notify stakeholders of completion
- [ ] Update documentation and runbooks

### Short-term Tasks (Week 1)
- [ ] Upgrade Capsule servers
- [ ] Update content views and lifecycles
- [ ] Review and update custom configurations
- [ ] Validate reporting and metrics
- [ ] Train staff on new features

### Long-term Tasks (Month 1)
- [ ] Evaluate new features and capabilities
- [ ] Update automation and integrations
- [ ] Review and optimize performance
- [ ] Plan next upgrade cycle
- [ ] Document lessons learned

## Red Hat Support Resources

### Before Upgrade
- **Upgrade Helper:** https://access.redhat.com/labs/satelliteupgradehelper/
- **Documentation:** https://access.redhat.com/documentation/en-us/red_hat_satellite/
- **Release Notes:** Review target version release notes

### During Upgrade
- **Support Case:** Create proactive support case
- **Log Collection:** Gather logs for analysis
- **Expert Assistance:** Engage Red Hat support if issues arise

### After Upgrade
- **Health Verification:** Validate upgrade success
- **Performance Monitoring:** Monitor system performance
- **Issue Resolution:** Address any remaining concerns

---
*This checklist ensures comprehensive upgrade planning and execution following Red Hat best practices and the Satellite Maintenance & Remediation tool procedures.*
