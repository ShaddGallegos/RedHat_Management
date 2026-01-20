# Operations - Backup and Recovery

Complete guide for backing up and recovering RHIS components.

## Backup Strategy

### Backup Frequency

```
Daily Backups:
- AAP databases (incremental)
- Satellite databases (incremental)
- IdM configuration

Weekly Backups:
- Full AAP backup (database + configurations)
- Full Satellite backup (database + repositories)
- Full IdM backup (directory + certificates)

Monthly Backups:
- Complete system snapshot
- Archive old backups
- Test recovery procedures
```

### Backup Locations

```
/backup/
 aap/
    daily/
    weekly/
    monthly/
 scenario_satellite/
    daily/
    weekly/
    monthly/
 idm/
    daily/
    weekly/
    monthly/
 system-snapshots/
     monthly/
```

## AAP Backup and Recovery

### Database Backup

```bash
# Full database backup
sudo docker exec aap-postgres-1 pg_dump -U awx awx > /backup/aap/daily/aap-db-$(date +%Y%m%d).sql

# Backup with compression
sudo docker exec aap-postgres-1 pg_dump -U awx -F custom awx > /backup/aap/daily/aap-db-$(date +%Y%m%d).dump

# Backup all databases
sudo docker exec aap-postgres-1 pg_dumpall -U awx > /backup/aap/daily/aap-all-$(date +%Y%m%d).sql
```

### Full System Backup

```bash
# Include secrets, configurations, and data
tar czf /backup/aap/weekly/aap-full-$(date +%Y%m%d).tar.gz \
  /opt/aap-setup \
  /var/lib/docker/volumes \
  /etc/aap/ \
  /var/log/containers/

# Verify backup integrity
tar tzf /backup/aap/weekly/aap-full-$(date +%Y%m%d).tar.gz | head -20
```

### Database Recovery

```bash
# Restore from SQL dump
sudo docker exec aap-postgres-1 psql -U awx awx < /backup/aap/daily/aap-db-20240116.sql

# Restore from custom dump
sudo docker exec aap-postgres-1 pg_restore -U awx -d awx /backup/aap/daily/aap-db-20240116.dump

# Verify restoration
sudo docker exec aap-postgres-1 psql -U awx awx -c "SELECT COUNT(*) FROM main_job;"
```

### Full System Recovery

```bash
# Stop AAP
sudo docker-compose -f /opt/aap-setup/docker-compose.yml down

# Restore from full backup
cd /
sudo tar xzf /backup/aap/weekly/aap-full-20240116.tar.gz

# Start AAP
sudo docker-compose -f /opt/aap-setup/docker-compose.yml up -d

# Verify services
sudo docker-compose -f /opt/aap-setup/docker-compose.yml ps
```

## Satellite Backup and Recovery

### Database Backup

```bash
# Use Satellite backup utility
sudo scenario_satellite-backup --verbose /backup/scenario_satellite/weekly/

# Backup directory contains:
# - scenario_satellite.log
# - foreman-backup-TIMESTAMP.tar.gz
# - candlepin-backup-TIMESTAMP.tar.gz
# - pulp-backup-TIMESTAMP.tar.gz
```

### Incremental Backup

```bash
# After first full backup, use incremental
sudo scenario_satellite-backup --incremental /backup/scenario_satellite/daily/

# Smaller backup size, faster execution
# Requires full backup as base
```

### Repository Snapshot

```bash
# Export repository data
mkdir -p /backup/scenario_satellite/repos/
tar czf /backup/scenario_satellite/repos/repos-$(date +%Y%m%d).tar.gz \
  /var/lib/pulp/

# This captures published repository content
du -sh /backup/scenario_satellite/repos/
```

### Satellite Recovery

```bash
# Restore from scenario_satellite-backup
sudo scenario_satellite-restore \
  --verbose \
  /backup/scenario_satellite/weekly/scenario_satellite-backup-2024.01.16.tar.gz

# Restoration steps:
# 1. Stops services
# 2. Restores databases
# 3. Restores configuration
# 4. Restarts services
# 5. Verifies restoration

# Monitor restoration
sudo tail -100f /var/log/foreman-installer/scenario_satellite.log
```

## IdM Backup and Recovery

### Configuration Backup

```bash
# Full IdM backup
sudo ipa-backup --verbose --logs /backup/idm/weekly/

# Backup includes:
# - Directory server data
# - Configuration
# - Certificates
# - Logs
```

### Manual Backup

```bash
# Backup directory database
sudo tar czf /backup/idm/daily/dirsrv-$(date +%Y%m%d).tar.gz \
  /var/lib/dirsrv/

# Backup Kerberos data
sudo tar czf /backup/idm/daily/krb5-$(date +%Y%m%d).tar.gz \
  /var/kerberos/

# Backup certificates
sudo tar czf /backup/idm/daily/certs-$(date +%Y%m%d).tar.gz \
  /etc/pki/
```

### IdM Recovery

```bash
# Restore using ipa-backup-restore
sudo ipa-backup-restore --verbose /backup/idm/weekly/ipabackup-20240116.tar.gz

# Or manual restore:
sudo systemctl stop ipa
sudo tar xzf /backup/idm/daily/dirsrv-20240116.tar.gz -C /
sudo systemctl start ipa

# Verify services
sudo ipactl status
```

## Virtualized Environment Backups

### VM Snapshots

```bash
# Create VM snapshot before updates
virsh snapshot-create-as prod-scenario_satellite \
  --name pre-update \
  --description "Snapshot before package updates"

# List snapshots
virsh snapshot-list prod-scenario_satellite

# Revert to snapshot
virsh snapshot-revert prod-scenario_satellite pre-update

# Delete snapshot
virsh snapshot-delete prod-scenario_satellite pre-update
```

### VM Disk Backup

```bash
# Full VM disk backup
cp /var/lib/libvirt/images/prod-scenario_satellite.qcow2 \
   /backup/vms/prod-scenario_satellite-$(date +%Y%m%d).qcow2

# Compress backup
gzip /backup/vms/prod-scenario_satellite-20240116.qcow2

# Verify backup
qemu-img info /backup/vms/prod-scenario_satellite-20240116.qcow2.gz
```

## Backup Automation

### Backup Script

Create `/usr/local/bin/backup-rhis.sh`:

```bash
#!/bin/bash

BACKUP_ROOT="/backup"
BACKUP_DATE=$(date +%Y%m%d)
LOG_FILE="/var/log/backup-rhis-${BACKUP_DATE}.log"

echo "Starting RHIS backup at $(date)" | tee -a $LOG_FILE

# AAP Backup
echo "Backing up AAP..." | tee -a $LOG_FILE
sudo docker exec aap-postgres-1 pg_dump -U awx awx | \
  gzip > ${BACKUP_ROOT}/aap/daily/aap-db-${BACKUP_DATE}.sql.gz 2>&1 | tee -a $LOG_FILE

# Satellite Backup
echo "Backing up Satellite..." | tee -a $LOG_FILE
sudo scenario_satellite-backup ${BACKUP_ROOT}/scenario_satellite/daily/ >> $LOG_FILE 2>&1

# IdM Backup
echo "Backing up IdM..." | tee -a $LOG_FILE
sudo ipa-backup ${BACKUP_ROOT}/idm/daily/ >> $LOG_FILE 2>&1

echo "Backup completed at $(date)" | tee -a $LOG_FILE
```

### Cron Schedule

```bash
# Add to root crontab
sudo crontab -e

# Daily backups at 2 AM
0 2 * * * /usr/local/bin/backup-rhis.sh

# Weekly full backup every Sunday at 1 AM
0 1 * * 0 /usr/local/bin/backup-rhis-full.sh
```

## Backup Verification

### Test Restoration Regularly

```bash
# Weekly restoration test
mkdir -p /tmp/test-restore
cd /tmp/test-restore

# Extract backup
tar xzf /backup/aap/daily/aap-db-20240116.sql.gz

# Test database import (on test system)
psql test_db < aap-db-20240116.sql

# Verify data integrity
psql -d test_db -c "SELECT COUNT(*) FROM main_job;"
```

### Backup Integrity Checks

```bash
# Verify backup completeness
ls -lh /backup/aap/daily/
ls -lh /backup/scenario_satellite/daily/
ls -lh /backup/idm/daily/

# Check backup age (should be recent)
find /backup -name "*.tar.gz" -mtime +1 -print

# Check backup size (should not be zero)
find /backup -size 0
```

## Disaster Recovery Procedure

### Step 1: Assess Damage

```bash
# Check what's lost
systemctl status aap scenario_satellite ipa
docker ps -a
sudo ipactl status
```

### Step 2: Prepare Recovery System

```bash
# On recovery target:
sudo yum update -y
sudo yum install -y docker postgresql python3

# Restore network configuration if needed
sudo nmcli connection modify "System eth0" ipv4.addresses "192.168.1.10/24"
sudo nmcli connection up "System eth0"
```

### Step 3: Restore Services

```bash
# Restore in order:
# 1. IdM (foundation for authentication)
sudo ipa-backup-restore /backup/idm/weekly/ipabackup-latest.tar.gz

# 2. Satellite (dependency for AAP)
sudo scenario_satellite-restore /backup/scenario_satellite/weekly/scenario_satellite-backup-latest.tar.gz

# 3. AAP (depends on IdM, Satellite)
docker exec aap-postgres-1 psql -U awx awx < /backup/aap/weekly/aap-db-latest.sql
```

### Step 4: Verify Restoration

```bash
# Test each component
curl -k https://idm.example.com/ipa/json
curl -k https://scenario_satellite.example.com/api/v2/
curl -k https://aap.example.com/api/v2/

# Verify integrations
ipa user-find admin
hammer host list
awx-cli config show
```

## Retention Policy

### Backup Retention

```
Daily backups:     Keep for 7 days
Weekly backups:    Keep for 4 weeks
Monthly backups:   Keep for 12 months
Disaster snapshots: Keep indefinitely (offline storage)
```

### Cleanup Script

```bash
#!/bin/bash
# Remove old backups

find /backup/aap/daily -name "*.gz" -mtime +7 -delete
find /backup/aap/weekly -name "*.gz" -mtime +28 -delete
find /backup/scenario_satellite/daily -name "*.tar.gz" -mtime +7 -delete
find /backup/scenario_satellite/weekly -name "*.tar.gz" -mtime +28 -delete

echo "Old backups removed"
```

---

See [Operations](.) for other operations guides and [Troubleshooting](../troubleshooting/) for recovery troubleshooting.
