# Red Hat Satellite Maintenance & Remediation

A comprehensive automation toolkit for Red Hat Satellite maintenance, health monitoring, backup, and upgrade procedures following Red Hat best practices.

## Overview

This project provides automated maintenance and remediation capabilities for Red Hat Satellite environments, including proactive support case creation, comprehensive health checks, system backups, and guided upgrade procedures.

## Features

### Core Functionality
- **Automated Support Case Creation**: Proactive Red Hat support case creation using redhat-support-tool
- **Comprehensive Health Checks**: Detailed foreman-maintain health assessment
- **SOS Report Generation**: Automated diagnostic data collection with Satellite-specific plugins
- **System Snapshots**: Platform-aware snapshot creation (LVM, VMware, KVM)
- **System Backups**: Complete satellite-maintain backup with proper system preparation
- **Repository Management**: Version-specific repository configuration for RHEL 8/9
- **Guided Upgrades**: Step-by-step Satellite upgrade following Red Hat guidelines
- **Detailed Reporting**: Comprehensive maintenance reports in Markdown format
- **Comprehensive Support Tickets**: Advanced ticket creation with complete system analysis, log review, errata assessment, and SOS report integration

### Best Practices Implementation
- **Version-specific Upgrade Paths**: Only one y-stream upgrade at a time (6.15→6.16→6.17)
- **Pre-upgrade Preparation**: Automatic firewall/SELinux configuration for backups
- **Safety Measures**: System snapshot recommendations and backup verification
- **Comprehensive Logging**: Detailed activity logging for audit and troubleshooting
- **Error Handling**: Robust error detection and recovery procedures

## System Requirements

### Supported Environments
- Red Hat Satellite 6.15, 6.16, or 6.17
- Red Hat Enterprise Linux 8 or 9
- Valid Red Hat subscriptions and entitlements

### Required Packages
- `foreman-maintain` - Satellite maintenance utility
- `sos` - System diagnostic data collection
- `redhat-support-tool` - Red Hat Customer Portal integration
- `subscription-manager` - Red Hat subscription management
- `lvm2` - Logical Volume Manager (for snapshots)

### Prerequisites
- Root or sudo privileges
- Valid Red Hat Customer Portal credentials
- Network connectivity to Red Hat services
- Sufficient disk space for backups and snapshots

## Installation

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd Red_Hat_Satellite_Maint-Remediation
   ```

2. **Make Script Executable**
   ```bash
   chmod +x satellite-maintenance.sh
   ```

3. **Install Required Packages**
   ```bash
   sudo dnf install -y foreman-maintain sos redhat-support-tool subscription-manager
   ```

4. **Configure Red Hat Support Tool**
   ```bash
   redhat-support-tool config
   ```

## Usage

### Interactive Mode (Recommended)
Run the script without arguments to access the interactive menu:
```bash
./satellite-maintenance.sh
```

### Command Line Options
```bash
./satellite-maintenance.sh [OPTIONS]

Options:
  -h, --help           Show help message and exit
  -c, --case           Create Red Hat support case
  -k, --health-check   Run foreman-maintain health check
  -s, --sos-report     Generate SOS report
  -b, --backup         Create system backup
  -u, --upgrade        Run guided upgrade process
  -r, --report         Generate maintenance report
  --version VERS       Specify Satellite version (6.15, 6.16, 6.17)
```

### Examples
```bash
# Show interactive menu
./satellite-maintenance.sh

# Run health check only
./satellite-maintenance.sh --health-check

# Create comprehensive support ticket with analysis
./satellite-maintenance.sh --ticket

# Create backup with version specification
./satellite-maintenance.sh --backup --version 6.17

# Run complete maintenance workflow
./satellite-maintenance.sh --version 6.16
```

## Menu Options

### 1. Check Prerequisites
Validates system requirements:
- Package availability (foreman-maintain, sos, redhat-support-tool)
- RHEL version compatibility
- Satellite installation detection
- Subscription status verification
- Privilege requirements

### 2. Create Red Hat Support Case
Automated support case creation:
- Gathers system information automatically
- Creates proactive maintenance case
- Uses redhat-support-tool integration
- Provides manual fallback instructions

### 3. Run Health Check
Comprehensive health assessment:
- Executes `foreman-maintain health check --detailed`
- Categorizes results (PASS/WARN/FAIL)
- Generates detailed health reports
- Identifies critical issues requiring attention

### 4. Generate SOS Report
Diagnostic data collection:
- Creates comprehensive system report
- Uses Satellite-specific plugins
- Includes all relevant log files
- Optimized for Red Hat support analysis

### 5. Create System Snapshot
Platform-aware snapshot creation:
- Detects virtualization platform
- Provides platform-specific guidance
- Supports LVM snapshot creation
- Recommends hypervisor-level snapshots

### 6. Create System Backup
Complete system backup procedure:
- Temporarily disables firewall
- Sets SELinux to permissive mode
- Executes `satellite-maintain backup offline`
- Restores system settings post-backup
- Verifies backup integrity

### 7. Configure Repositories
Version-specific repository management:
- Disables all existing repositories
- Enables correct repositories for target version
- Supports RHEL 8 and RHEL 9
- Verifies repository accessibility

### 8. Run Satellite Upgrade
Guided upgrade procedure:
- Validates upgrade path (one y-stream only)
- Configures appropriate repositories
- Updates core packages
- Executes `foreman-maintain upgrade run`
- Verifies upgrade completion

### 9. Complete Maintenance Workflow
End-to-end maintenance procedure:
1. Create support case
2. Run health check
3. Generate SOS report
4. Upload files to support case
5. Create system snapshot
6. Create system backup
7. Generate comprehensive report

### 10. Generate Maintenance Report
Creates detailed Markdown report:
- Executive summary
- System information
- Activity documentation
- Results compilation
- Next steps recommendations

### 11. View Logs
Displays available log files:
- Shows recent log files in `/var/log/satellite-maintenance/`
- Allows interactive log viewing
- Provides log file filtering options

### 12. Create Comprehensive Support Ticket
Advanced ticket creation with complete system analysis:
- **Health Check Analysis**: Full foreman-maintain health assessment with categorized results
- **Available Errata Review**: Security updates and package availability analysis
- **System Log Analysis**: Automated review of /var/log/* files for errors, warnings, and anomalies
- **Resource Assessment**: Disk space, memory usage, and load average evaluation
- **Service Status Check**: Satellite services health and database connectivity
- **SOS Report Integration**: Automatic SOS report generation with Satellite-specific plugins
- **Automatic File Upload**: All analysis files and SOS report uploaded to Red Hat support case
- **Professional Documentation**: Comprehensive case description with executive summary

This option provides the most thorough analysis and creates a complete support ticket with all relevant system information, making it ideal for proactive maintenance or when comprehensive technical support is needed.

## File Structure

```
Red_Hat_Satellite_Maint-Remediation/
├── satellite-maintenance.sh    # Main script
├── README.md                   # This documentation
├── CHANGELOG.md               # Version history
├── LICENSE                    # License information
└── examples/                  # Usage examples
    ├── health-check-report.md
    ├── backup-procedure.md
    └── upgrade-checklist.md
```

## Generated Files and Directories

### Log Directory: `/var/log/satellite-maintenance/`
- `satellite-maintenance-YYYYMMDD_HHMMSS.log` - Main activity log
- `health-check-YYYYMMDD_HHMMSS.log` - Health check detailed results
- `backup-YYYYMMDD_HHMMSS.log` - Backup operation log
- `upgrade-VERSION-YYYYMMDD_HHMMSS.log` - Upgrade process log
- `sos-creation-YYYYMMDD_HHMMSS.log` - SOS report generation log

### Backup Directory: `/var/backup/satellite/`
- `backup-YYYYMMDD_HHMMSS/` - Satellite backup directories
- Contains complete offline backup data

### Report Directory: `/var/reports/satellite/`
- `satellite-maintenance-report-YYYYMMDD_HHMMSS.md` - Maintenance reports
- `health-check-YYYYMMDD_HHMMSS.txt` - Health check summaries

## Upgrade Guidelines

### Supported Upgrade Paths
- **6.15 → 6.16** (Supported)
- **6.16 → 6.17** (Supported)
- **6.15 → 6.17** (Not Supported - Must go through 6.16)

### Upgrade Sequence
1. **Pre-upgrade**: Health check, backup, snapshot
2. **Repository Configuration**: Enable target version repositories
3. **Package Updates**: Update satellite-installer and foreman-maintain
4. **Dependency Building**: Build required dependencies
5. **Upgrade Execution**: Run foreman-maintain upgrade
6. **Post-upgrade**: Package updates and verification

### Important Notes
- Always upgrade Satellite before upgrading RHEL OS
- Capsule servers can run one version behind temporarily
- Review release notes before upgrading
- Use Red Hat's Satellite Upgrade Helper for planning

## Repository Configuration

### RHEL 9 Repositories
```bash
rhel-9-for-x86_64-baseos-rpms
rhel-9-for-x86_64-appstream-rpms
satellite-utils-{version}-for-rhel-9-x86_64-rpms
satellite-maintenance-{version}-for-rhel-9-x86_64-rpms
satellite-{version}-for-rhel-9-x86_64-rpms
```

### RHEL 8 Repositories
```bash
rhel-8-for-x86_64-baseos-rpms
rhel-8-for-x86_64-appstream-rpms
satellite-utils-{version}-for-rhel-8-x86_64-rpms
satellite-maintenance-{version}-for-rhel-8-x86_64-rpms
satellite-{version}-for-rhel-8-x86_64-rpms
```

## Error Handling

### Common Issues and Solutions

**Permission Denied**
- Ensure script is run with sudo or as root
- Verify SELinux contexts if running in enforcing mode

**Package Not Found**
- Install required packages: `sudo dnf install -y foreman-maintain sos redhat-support-tool`
- Verify Red Hat subscriptions are active

**Repository Access Issues**
- Check subscription-manager status
- Verify repository enablement
- Confirm network connectivity

**Backup Failures**
- Ensure sufficient disk space (typically 2-3x database size)
- Verify SELinux is set to permissive during backup
- Check firewall status

**Upgrade Failures**
- Review upgrade logs in detail
- Verify prerequisite packages are updated
- Check for disk space and memory requirements

### Debug Mode
Enable detailed logging:
```bash
export DEBUG=1
./satellite-maintenance.sh
```

## Security Considerations

- **Credential Management**: Red Hat Support Tool credentials stored securely
- **Privilege Requirements**: Script requires elevated privileges for system operations
- **Firewall Handling**: Temporary firewall disable during backup (restored automatically)
- **SELinux Management**: Temporary permissive mode during backup (restored automatically)
- **Log Security**: Sensitive information filtered from logs

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow Red Hat best practices
4. Test thoroughly in lab environment
5. Submit pull request with detailed description

## Support Resources

- **Red Hat Satellite Documentation**: https://access.redhat.com/documentation/en-us/red_hat_satellite/
- **Satellite Upgrade Helper**: https://access.redhat.com/labs/satelliteupgradehelper/
- **Red Hat Support**: https://access.redhat.com/support/
- **Foreman-maintain Documentation**: https://access.redhat.com/documentation/en-us/red_hat_satellite/6.16/html/administering_red_hat_satellite/using-foreman-maintain_admin

## License

This project is provided for educational and operational use. Please review and comply with your organization's policies regarding script usage and Red Hat system administration.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

---

**Note**: This tool is designed for production Red Hat Satellite environments. Always test in a lab environment before using with critical systems. Ensure proper backup and snapshot procedures are in place before running maintenance operations.
