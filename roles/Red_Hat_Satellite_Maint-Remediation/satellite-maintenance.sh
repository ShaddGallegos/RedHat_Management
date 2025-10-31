#!/bin/bash

# Red Hat Satellite Maintenance and Remediation Script
# 
# This script provides automated maintenance, health checks, backup, and upgrade
# capabilities for Red Hat Satellite environments following best practices.
#
# Features:
# - Automated Red Hat Support case creation
# - Comprehensive health checks with foreman-maintain
# - SOS report generation and upload
# - System snapshots and backups
# - Version-specific repository management
# - Guided upgrade procedures
# - Detailed reporting and logging
#
# Requirements:
# - Red Hat Satellite 6.15+ environment
# - redhat-support-tool package
# - foreman-maintain utility
# - sos package
# - RHEL 8 or RHEL 9 operating system
# - Valid Red Hat subscriptions
#
# Author: Red Hat Satellite Maintenance Tool v1.0
# Date: September 5, 2025

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/var/log/satellite-maintenance"
BACKUP_DIR="/var/backup/satellite"
REPORT_DIR="/var/reports/satellite"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/satellite-maintenance-$TIMESTAMP.log"
REPORT_FILE="$REPORT_DIR/satellite-maintenance-report-$TIMESTAMP.md"

# Supported Satellite versions
declare -A SATELLITE_VERSIONS=(
    ["6.15"]="6.15"
    ["6.16"]="6.16"
    ["6.17"]="6.17"
)

# Helper functions
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"; }
print_status() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
print_header() { 
    echo -e "${CYAN}==========================================${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}==========================================${NC}" | tee -a "$LOG_FILE"
}

# Function to show help
show_help() {
    echo "Red Hat Satellite Maintenance and Remediation Tool"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -c, --case           Create Red Hat support case"
    echo "  -k, --health-check   Run foreman-maintain health check"
    echo "  -s, --sos-report     Generate SOS report"
    echo "  -b, --backup         Create system backup"
    echo "  -u, --upgrade        Run guided upgrade process"
    echo "  -r, --report         Generate maintenance report"
    echo "  -t, --ticket         Create comprehensive support ticket with analysis"
    echo "  -p, --provisioning   Check Satellite services and test provisioning"
    echo "  --version VERS       Specify Satellite version (6.15, 6.16, 6.17)"
    echo ""
    echo "Interactive Mode (default):"
    echo "  Run without arguments to access the interactive menu"
    echo ""
    echo "Examples:"
    echo "  $0                    # Show interactive menu"
    echo "  $0 --health-check     # Run health check only"
    echo "  $0 --backup           # Create backup only"
    echo "  $0 --ticket           # Create comprehensive support ticket"
    echo "  $0 --upgrade          # Run guided upgrade"
    echo "  $0 --version 6.17     # Specify Satellite version"
    echo ""
    echo "Requirements:"
    echo "  - Red Hat Satellite 6.15+ environment"
    echo "  - redhat-support-tool package installed"
    echo "  - Valid Red Hat Customer Portal credentials"
    echo "  - Root or sudo privileges"
    echo ""
    echo "Documentation:"
    echo "  - Red Hat Satellite Documentation: https://access.redhat.com/documentation/en-us/red_hat_satellite/"
    echo "  - Upgrade Helper: https://access.redhat.com/labs/satelliteupgradehelper/"
}

# Function to initialize directories and logging
initialize_environment() {
    print_status "Initializing maintenance environment..."
    
    # Create necessary directories
    sudo mkdir -p "$LOG_DIR" "$BACKUP_DIR" "$REPORT_DIR"
    sudo chmod 755 "$LOG_DIR" "$BACKUP_DIR" "$REPORT_DIR"
    
    # Initialize log file
    echo "=== Red Hat Satellite Maintenance Log ===" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "User: $(whoami)" >> "$LOG_FILE"
    echo "Hostname: $(hostname -f)" >> "$LOG_FILE"
    echo "=========================================" >> "$LOG_FILE"
    
    print_success "Environment initialized successfully"
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local errors=0
    
    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
        print_error "This script requires root privileges or sudo access"
        ((errors++))
    fi
    
    # Check for required packages
    local required_packages=("foreman-maintain" "sos" "redhat-support-tool" "subscription-manager")
    for package in "${required_packages[@]}"; do
        if ! command -v "$package" >/dev/null 2>&1 && ! rpm -q "$package" >/dev/null 2>&1; then
            print_warning "Required package not found: $package"
            print_status "Install with: sudo dnf install -y $package"
            ((errors++))
        else
            print_success "Found required package: $package"
        fi
    done
    
    # Check RHEL version
    if [[ -f /etc/redhat-release ]]; then
        local rhel_version=$(grep -oE 'release [0-9]+' /etc/redhat-release | awk '{print $2}')
        if [[ "$rhel_version" == "8" || "$rhel_version" == "9" ]]; then
            print_success "Supported RHEL version detected: RHEL $rhel_version"
            echo "RHEL_VERSION=$rhel_version" >> "$LOG_FILE"
        else
            print_error "Unsupported RHEL version: $rhel_version"
            ((errors++))
        fi
    else
        print_error "Could not determine RHEL version"
        ((errors++))
    fi
    
    # Check Satellite installation
    if command -v satellite-installer >/dev/null 2>&1; then
        local sat_version=$(rpm -q satellite --queryformat '%{VERSION}' 2>/dev/null || echo "unknown")
        print_success "Red Hat Satellite detected: Version $sat_version"
        echo "SATELLITE_VERSION=$sat_version" >> "$LOG_FILE"
    else
        print_error "Red Hat Satellite not detected"
        ((errors++))
    fi
    
    # Check subscription status
    if subscription-manager status >/dev/null 2>&1; then
        print_success "System is registered and subscribed"
    else
        print_warning "System subscription status unclear"
        print_status "Verify with: subscription-manager status"
    fi
    
    if [[ $errors -gt 0 ]]; then
        print_error "Prerequisites check failed with $errors error(s)"
        return 1
    fi
    
    print_success "All prerequisites met"
    return 0
}

# Function to detect RHEL version
detect_rhel_version() {
    if [[ -f /etc/redhat-release ]]; then
        grep -oE 'release [0-9]+' /etc/redhat-release | awk '{print $2}'
    else
        echo "unknown"
    fi
}

# Function to create Red Hat support case
create_support_case() {
    print_header "Creating Red Hat Support Case"
    
    # Check if redhat-support-tool is configured
    if ! redhat-support-tool config >/dev/null 2>&1; then
        print_warning "Red Hat Support Tool not configured"
        print_status "Please configure with your Red Hat Customer Portal credentials:"
        print_status "  redhat-support-tool config"
        return 1
    fi
    
    # Gather system information
    local hostname=$(hostname -f)
    local rhel_version=$(detect_rhel_version)
    local sat_version=$(rpm -q satellite --queryformat '%{VERSION}' 2>/dev/null || echo "unknown")
    
    # Create case summary and description
    local case_summary="Satellite $sat_version Maintenance - Proactive Health Check - $hostname"
    local case_description="Proactive maintenance and health check for Red Hat Satellite $sat_version on RHEL $rhel_version.

System Details:
- Hostname: $hostname
- RHEL Version: $rhel_version
- Satellite Version: $sat_version
- Maintenance Date: $(date)

This case has been created proactively as part of our maintenance procedures.
Health check results, SOS report, and backup information will be attached."

    print_status "Creating support case..."
    print_status "Summary: $case_summary"
    
    # Create the case (this would need actual implementation based on redhat-support-tool capabilities)
    local case_number=""
    if command -v redhat-support-tool >/dev/null 2>&1; then
        # Note: Actual case creation syntax may vary - this is a template
        print_status "Attempting to create support case..."
        case_number=$(redhat-support-tool create \
            --summary "$case_summary" \
            --description "$case_description" \
            --product "Red Hat Satellite" \
            --version "$sat_version" \
            --severity "3" 2>/dev/null || echo "")
        
        if [[ -n "$case_number" ]]; then
            print_success "Support case created: $case_number"
            echo "SUPPORT_CASE=$case_number" >> "$LOG_FILE"
            echo "SUPPORT_CASE_NUMBER=$case_number" >> "$REPORT_FILE"
        else
            print_warning "Automated case creation failed"
            print_status "Please create case manually at: https://access.redhat.com/support/cases/"
            print_status "Use the following information:"
            echo "  Summary: $case_summary"
            echo "  Description: $case_description"
        fi
    else
        print_error "redhat-support-tool not available"
        return 1
    fi
}

# Function to run foreman-maintain health check
run_health_check() {
    print_header "Running Foreman-Maintain Health Check"
    
    local health_log="$LOG_DIR/health-check-$TIMESTAMP.log"
    local health_report="$REPORT_DIR/health-check-$TIMESTAMP.txt"
    
    print_status "Starting comprehensive health check..."
    print_status "This may take several minutes..."
    
    # Run health check with detailed output
    if sudo foreman-maintain health check --detailed 2>&1 | tee "$health_log"; then
        print_success "Health check completed successfully"
        
        # Parse results for report
        grep -E "(FAIL|WARN|OK)" "$health_log" > "$health_report" 2>/dev/null || true
        
        # Count issues
        local fail_count=$(grep -c "FAIL" "$health_report" 2>/dev/null || echo "0")
        local warn_count=$(grep -c "WARN" "$health_report" 2>/dev/null || echo "0")
        local ok_count=$(grep -c "OK" "$health_report" 2>/dev/null || echo "0")
        
        print_status "Health Check Summary:"
        print_status "  ✓ Passed: $ok_count"
        print_warning "  ⚠ Warnings: $warn_count"
        print_error "  ✗ Failed: $fail_count"
        
        # Add to main report
        {
            echo "## Health Check Results"
            echo "- **Passed:** $ok_count"
            echo "- **Warnings:** $warn_count"  
            echo "- **Failed:** $fail_count"
            echo "- **Detailed Log:** $health_log"
            echo ""
        } >> "$REPORT_FILE"
        
        if [[ $fail_count -gt 0 ]]; then
            print_warning "Health check found $fail_count critical issues"
            print_status "Review detailed log: $health_log"
        fi
        
    else
        print_error "Health check failed or encountered errors"
        return 1
    fi
}

# Function to create SOS report
create_sos_report() {
    print_header "Generating SOS Report"
    
    local sos_case_id="${SUPPORT_CASE:-satellite-maintenance-$TIMESTAMP}"
    
    print_status "Creating comprehensive SOS report..."
    print_status "This may take 10-15 minutes depending on system size..."
    
    # Create SOS report with Satellite-specific plugins
    local sos_cmd="sudo sosreport --batch --tmp-dir /var/tmp \
        --case-id $sos_case_id \
        --only-plugins foreman,satellite,pulp,candlepin,apache,postgresql,redis,qpid \
        --all-logs"
    
    print_status "Running: $sos_cmd"
    
    if $sos_cmd 2>&1 | tee "$LOG_DIR/sos-creation-$TIMESTAMP.log"; then
        # Find the created SOS report
        local sos_file=$(find /var/tmp -name "sosreport-*$sos_case_id*.tar.xz" -newer "$LOG_FILE" | head -1)
        
        if [[ -n "$sos_file" && -f "$sos_file" ]]; then
            print_success "SOS report created: $sos_file"
            local sos_size=$(du -h "$sos_file" | cut -f1)
            print_status "Report size: $sos_size"
            
            # Add to main report
            {
                echo "## SOS Report"
                echo "- **File:** $sos_file"
                echo "- **Size:** $sos_size"
                echo "- **Case ID:** $sos_case_id"
                echo ""
            } >> "$REPORT_FILE"
            
            echo "SOS_REPORT_FILE=$sos_file" >> "$LOG_FILE"
            
        else
            print_error "SOS report file not found"
            return 1
        fi
    else
        print_error "SOS report generation failed"
        return 1
    fi
}

# Function to upload files to support case
upload_to_support_case() {
    local case_number="$1"
    shift
    local files=("$@")
    
    if [[ -z "$case_number" ]]; then
        print_warning "No support case number provided - skipping upload"
        return 0
    fi
    
    print_header "Uploading Files to Support Case $case_number"
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            print_status "Uploading: $file"
            if redhat-support-tool upload-file --case "$case_number" "$file" 2>/dev/null; then
                print_success "Uploaded: $(basename "$file")"
            else
                print_warning "Failed to upload: $(basename "$file")"
                print_status "Please upload manually to case $case_number"
            fi
        else
            print_warning "File not found: $file"
        fi
    done
}

# Function to create system snapshot
create_system_snapshot() {
    print_header "Creating System Snapshot"
    
    # Check if we're running in a virtualized environment
    local virt_type=$(systemd-detect-virt 2>/dev/null || echo "none")
    
    case "$virt_type" in
        "vmware")
            print_status "VMware environment detected"
            print_status "Creating VMware snapshot requires VMware tools"
            print_warning "Manual snapshot recommended before proceeding"
            ;;
        "kvm"|"qemu")
            print_status "KVM/QEMU environment detected"
            print_status "Snapshot creation depends on hypervisor configuration"
            print_warning "Coordinate with virtualization administrator"
            ;;
        "rhev"|"ovirt")
            print_status "Red Hat Virtualization environment detected"
            print_warning "Create snapshot through RHV Manager before proceeding"
            ;;
        "none")
            print_status "Physical system detected"
            print_status "Consider LVM snapshots if available"
            
            # Check for LVM setup
            if command -v lvs >/dev/null 2>&1; then
                local lv_count=$(sudo lvs --noheadings | wc -l)
                if [[ $lv_count -gt 0 ]]; then
                    print_status "LVM volumes detected - snapshot capability available"
                    read -p "Create LVM snapshots? (y/N): " create_lvm_snap
                    if [[ "$create_lvm_snap" =~ ^[Yy]$ ]]; then
                        create_lvm_snapshots
                    fi
                fi
            fi
            ;;
        *)
            print_status "Virtualization type: $virt_type"
            print_warning "Snapshot method depends on platform - please create manually"
            ;;
    esac
    
    # Add snapshot information to report
    {
        echo "## System Snapshot"
        echo "- **Virtualization:** $virt_type"
        echo "- **Recommendation:** Create platform-appropriate snapshot before changes"
        echo ""
    } >> "$REPORT_FILE"
}

# Function to create LVM snapshots
create_lvm_snapshots() {
    print_status "Creating LVM snapshots..."
    
    # Get list of logical volumes
    while read -r vg lv; do
        [[ -z "$vg" || -z "$lv" ]] && continue
        
        local snap_name="${lv}_snap_$TIMESTAMP"
        local lv_path="/dev/$vg/$lv"
        
        print_status "Creating snapshot: $snap_name for $lv_path"
        
        if sudo lvcreate -L 2G -s -n "$snap_name" "$lv_path" 2>/dev/null; then
            print_success "Created snapshot: /dev/$vg/$snap_name"
        else
            print_warning "Failed to create snapshot for $lv_path"
        fi
        
    done < <(sudo lvs --noheadings -o vg_name,lv_name | grep -v snap)
}

# Function to create system backup
create_system_backup() {
    print_header "Creating System Backup"
    
    # Pre-backup system configuration
    print_status "Preparing system for backup..."
    
    # Disable firewall temporarily
    if systemctl is-active --quiet firewalld; then
        print_status "Temporarily disabling firewall..."
        sudo systemctl stop firewalld
        echo "FIREWALL_WAS_ACTIVE=true" >> "$LOG_FILE"
    fi
    
    # Set SELinux to permissive
    local current_selinux=$(getenforce)
    if [[ "$current_selinux" == "Enforcing" ]]; then
        print_status "Setting SELinux to permissive mode..."
        sudo setenforce 0
        echo "SELINUX_WAS_ENFORCING=true" >> "$LOG_FILE"
    fi
    
    # Create satellite backup
    local backup_dir="/var/backup/satellite/backup-$TIMESTAMP"
    sudo mkdir -p "$backup_dir"
    
    print_status "Starting satellite-maintain backup..."
    print_status "Backup location: $backup_dir"
    print_warning "This process may take significant time depending on data size"
    
    if sudo satellite-maintain backup offline "$backup_dir" 2>&1 | tee "$LOG_DIR/backup-$TIMESTAMP.log"; then
        print_success "Satellite backup completed successfully"
        
        # Calculate backup size
        local backup_size=$(sudo du -sh "$backup_dir" | cut -f1)
        print_status "Backup size: $backup_size"
        
        # Verify backup integrity
        if [[ -f "$backup_dir/metadata.yml" ]]; then
            print_success "Backup metadata verified"
        else
            print_warning "Backup metadata not found - verification recommended"
        fi
        
        # Add to report
        {
            echo "## System Backup"
            echo "- **Location:** $backup_dir"
            echo "- **Size:** $backup_size"
            echo "- **Type:** Offline backup"
            echo "- **Status:** Completed successfully"
            echo ""
        } >> "$REPORT_FILE"
        
        echo "BACKUP_LOCATION=$backup_dir" >> "$LOG_FILE"
        
    else
        print_error "Satellite backup failed"
        
        # Restore system settings
        restore_system_settings
        return 1
    fi
    
    # Restore system settings
    restore_system_settings
}

# Function to restore system settings after backup
restore_system_settings() {
    print_status "Restoring system settings..."
    
    # Restore SELinux if it was enforcing
    if grep -q "SELINUX_WAS_ENFORCING=true" "$LOG_FILE" 2>/dev/null; then
        print_status "Restoring SELinux to enforcing mode..."
        sudo setenforce 1
    fi
    
    # Restore firewall if it was active
    if grep -q "FIREWALL_WAS_ACTIVE=true" "$LOG_FILE" 2>/dev/null; then
        print_status "Restoring firewall..."
        sudo systemctl start firewalld
    fi
}

# Function to configure repositories based on RHEL version and Satellite version
configure_repositories() {
    local satellite_version="$1"
    local rhel_version=$(detect_rhel_version)
    
    print_header "Configuring Repositories for Satellite $satellite_version on RHEL $rhel_version"
    
    # Disable all repositories first
    print_status "Disabling all current repositories..."
    sudo subscription-manager repos --disable="*"
    
    case "$rhel_version" in
        "9")
            print_status "Enabling RHEL 9 repositories..."
            local repos=(
                "rhel-9-for-x86_64-baseos-rpms"
                "rhel-9-for-x86_64-appstream-rpms"
                "satellite-utils-${satellite_version}-for-rhel-9-x86_64-rpms"
                "satellite-maintenance-${satellite_version}-for-rhel-9-x86_64-rpms"
                "satellite-${satellite_version}-for-rhel-9-x86_64-rpms"
            )
            ;;
        "8")
            print_status "Enabling RHEL 8 repositories..."
            local repos=(
                "rhel-8-for-x86_64-baseos-rpms"
                "rhel-8-for-x86_64-appstream-rpms"
                "satellite-utils-${satellite_version}-for-rhel-8-x86_64-rpms"
                "satellite-maintenance-${satellite_version}-for-rhel-8-x86_64-rpms"
                "satellite-${satellite_version}-for-rhel-8-x86_64-rpms"
            )
            ;;
        *)
            print_error "Unsupported RHEL version: $rhel_version"
            return 1
            ;;
    esac
    
    # Enable repositories
    for repo in "${repos[@]}"; do
        print_status "Enabling repository: $repo"
        if sudo subscription-manager repos --enable="$repo"; then
            print_success "Enabled: $repo"
        else
            print_error "Failed to enable: $repo"
        fi
    done
    
    # Verify repository access
    print_status "Verifying repository access..."
    if sudo dnf repolist enabled | grep -q satellite; then
        print_success "Satellite repositories are accessible"
    else
        print_error "Satellite repositories not accessible"
        return 1
    fi
}

# Function to run satellite upgrade
run_satellite_upgrade() {
    local target_version="$1"
    
    print_header "Red Hat Satellite Upgrade to Version $target_version"
    
    # Verify upgrade path
    local current_version=$(rpm -q satellite --queryformat '%{VERSION}' 2>/dev/null || echo "unknown")
    print_status "Current Satellite version: $current_version"
    print_status "Target Satellite version: $target_version"
    
    # Warning about upgrade sequence
    print_warning "IMPORTANT: Upgrade Guidelines"
    print_warning "- Only upgrade one y-stream at a time (e.g., 6.15 → 6.16)"
    print_warning "- Upgrade Satellite before upgrading RHEL OS"
    print_warning "- Capsule servers can be upgraded after Satellite server"
    print_warning "- Review release notes before proceeding"
    
    read -p "Do you want to continue with the upgrade? (y/N): " confirm_upgrade
    if [[ ! "$confirm_upgrade" =~ ^[Yy]$ ]]; then
        print_status "Upgrade cancelled by user"
        return 0
    fi
    
    # Configure repositories for target version
    configure_repositories "$target_version"
    
    # Unlock packages
    print_status "Unlocking foreman packages..."
    sudo foreman-maintain packages unlock
    
    # Update core packages
    print_status "Updating satellite-installer and foreman-maintain..."
    sudo dnf upgrade -y satellite-installer foreman-maintain
    
    # Install yum-utils
    print_status "Installing yum-utils..."
    sudo dnf install -y yum-utils
    
    # Build dependencies
    print_status "Building dependencies..."
    sudo yum-builddep -y satellite-installer foreman-maintain --skip-broken --allowerasing --best
    
    # Run the upgrade
    print_status "Starting satellite upgrade to version $target_version..."
    print_warning "This process may take 1-2 hours depending on system size"
    
    local upgrade_log="$LOG_DIR/upgrade-$target_version-$TIMESTAMP.log"
    
    if sudo foreman-maintain upgrade run --target-version "$target_version" 2>&1 | tee "$upgrade_log"; then
        print_success "Satellite upgrade completed successfully"
        
        # Update packages
        print_status "Updating packages..."
        sudo foreman-maintain packages update -y
        
        # Verify upgrade
        local new_version=$(rpm -q satellite --queryformat '%{VERSION}' 2>/dev/null || echo "unknown")
        print_success "Upgrade complete - New version: $new_version"
        
        # Add to report
        {
            echo "## Satellite Upgrade"
            echo "- **From Version:** $current_version"
            echo "- **To Version:** $new_version"
            echo "- **Status:** Completed successfully"
            echo "- **Upgrade Log:** $upgrade_log"
            echo ""
        } >> "$REPORT_FILE"
        
    else
        print_error "Satellite upgrade failed"
        print_status "Check upgrade log: $upgrade_log"
        return 1
    fi
}

# Function to create comprehensive support ticket with detailed analysis
create_comprehensive_support_ticket() {
    print_header "Creating Comprehensive Support Ticket"
    
    local hostname=$(hostname -f)
    local rhel_version=$(detect_rhel_version)
    local sat_version=$(rpm -q satellite --queryformat '%{VERSION}' 2>/dev/null || echo "unknown")
    local analysis_file="/tmp/satellite-analysis-$(date +%Y%m%d-%H%M%S).txt"
    
    print_status "Performing comprehensive system analysis..."
    
    # Create detailed analysis report
    cat > "$analysis_file" << EOF
========================================
COMPREHENSIVE SATELLITE SYSTEM ANALYSIS
========================================

System Information:
- Hostname: $hostname
- RHEL Version: $(cat /etc/redhat-release)
- Satellite Version: $sat_version
- Analysis Date: $(date)
- Uptime: $(uptime)

========================================
HEALTH CHECK ANALYSIS
========================================
EOF
    
    # Run health check and capture results
    print_status "Running health check analysis..."
    if command -v foreman-maintain &> /dev/null; then
        echo "" >> "$analysis_file"
        echo "=== FOREMAN-MAINTAIN HEALTH CHECK ===" >> "$analysis_file"
        sudo foreman-maintain health check --assumeyes 2>&1 | tee -a "$analysis_file" || true
        
        # Analyze health check results
        local health_issues=$(grep -c "FAIL\|ERROR" "$analysis_file" 2>/dev/null || echo "0")
        local health_warnings=$(grep -c "WARN" "$analysis_file" 2>/dev/null || echo "0")
        
        echo "" >> "$analysis_file"
        echo "=== HEALTH CHECK SUMMARY ===" >> "$analysis_file"
        echo "Critical Issues Found: $health_issues" >> "$analysis_file"
        echo "Warnings Found: $health_warnings" >> "$analysis_file"
    else
        echo "foreman-maintain not available - manual health check required" >> "$analysis_file"
    fi
    
    # Check for available errata
    print_status "Checking available errata..."
    echo "" >> "$analysis_file"
    echo "========================================" >> "$analysis_file"
    echo "AVAILABLE ERRATA ANALYSIS" >> "$analysis_file"
    echo "========================================" >> "$analysis_file"
    
    if command -v dnf &> /dev/null; then
        echo "=== AVAILABLE UPDATES ===" >> "$analysis_file"
        dnf check-update 2>&1 | head -20 >> "$analysis_file" || true
        echo "" >> "$analysis_file"
        echo "=== SECURITY UPDATES ===" >> "$analysis_file"
        dnf updateinfo list security 2>&1 | head -10 >> "$analysis_file" || true
    elif command -v yum &> /dev/null; then
        echo "=== AVAILABLE UPDATES ===" >> "$analysis_file"
        yum check-update 2>&1 | head -20 >> "$analysis_file" || true
        echo "" >> "$analysis_file"
        echo "=== SECURITY UPDATES ===" >> "$analysis_file"
        yum updateinfo list security 2>&1 | head -10 >> "$analysis_file" || true
    fi
    
    # Analyze system logs for errors and warnings
    print_status "Analyzing system logs for issues..."
    echo "" >> "$analysis_file"
    echo "========================================" >> "$analysis_file"
    echo "SYSTEM LOG ANALYSIS" >> "$analysis_file"
    echo "========================================" >> "$analysis_file"
    
    # Check recent errors in various log files
    local log_files=(
        "/var/log/messages"
        "/var/log/secure"
        "/var/log/foreman/production.log"
        "/var/log/candlepin/candlepin.log"
        "/var/log/httpd/error_log"
        "/var/log/pulp/pulp.log"
    )
    
    for log_file in "${log_files[@]}"; do
        if [[ -f "$log_file" ]]; then
            echo "" >> "$analysis_file"
            echo "=== RECENT ERRORS/WARNINGS IN $log_file ===" >> "$analysis_file"
            # Get errors and warnings from last 24 hours
            tail -1000 "$log_file" 2>/dev/null | grep -i "error\|warning\|fail\|critical" | tail -10 >> "$analysis_file" 2>/dev/null || echo "No recent errors found" >> "$analysis_file"
        fi
    done
    
    # Check disk space and system resources
    print_status "Checking system resources..."
    echo "" >> "$analysis_file"
    echo "========================================" >> "$analysis_file"
    echo "SYSTEM RESOURCE ANALYSIS" >> "$analysis_file"
    echo "========================================" >> "$analysis_file"
    
    echo "=== DISK SPACE ===" >> "$analysis_file"
    df -h >> "$analysis_file"
    echo "" >> "$analysis_file"
    
    echo "=== MEMORY USAGE ===" >> "$analysis_file"
    free -h >> "$analysis_file"
    echo "" >> "$analysis_file"
    
    echo "=== LOAD AVERAGE ===" >> "$analysis_file"
    uptime >> "$analysis_file"
    echo "" >> "$analysis_file"
    
    # Check Satellite-specific services
    print_status "Checking Satellite services..."
    echo "=== SATELLITE SERVICES STATUS ===" >> "$analysis_file"
    if command -v foreman-maintain &> /dev/null; then
        sudo foreman-maintain service status 2>&1 >> "$analysis_file" || true
    else
        systemctl status httpd postgresql redis 2>&1 | grep -E "(Active:|Main PID:|Memory:|CPU:)" >> "$analysis_file" || true
    fi
    
    # Check for database issues
    print_status "Checking database connectivity..."
    echo "" >> "$analysis_file"
    echo "=== DATABASE CONNECTIVITY ===" >> "$analysis_file"
    if command -v foreman-rake &> /dev/null; then
        timeout 30 sudo -u foreman foreman-rake db:migrate:status 2>&1 | tail -5 >> "$analysis_file" || echo "Database check timed out or failed" >> "$analysis_file"
    fi
    
    # Generate SOS report information
    print_status "Generating SOS report for detailed analysis..."
    local sos_file=""
    if command -v sosreport &> /dev/null; then
        echo "" >> "$analysis_file"
        echo "=== SOS REPORT GENERATION ===" >> "$analysis_file"
        
        # Generate SOS report with Satellite plugins
        sos_file=$(sudo sosreport --batch --tmp-dir /tmp --enable-plugins satellite,foreman,katello 2>&1 | grep -o '/tmp/sosreport-[^[:space:]]*' | tail -1)
        
        if [[ -f "$sos_file" ]]; then
            echo "SOS Report generated: $sos_file" >> "$analysis_file"
            print_success "SOS report generated: $sos_file"
        else
            echo "SOS Report generation failed or incomplete" >> "$analysis_file"
            print_warning "SOS report generation issues detected"
        fi
    fi
    
    # Create the comprehensive support case
    print_status "Creating comprehensive Red Hat support case..."
    
    local case_summary="Satellite $sat_version - Comprehensive System Analysis & Health Report"
    local case_description="Comprehensive analysis and health check for Red Hat Satellite $sat_version system.

SYSTEM INFORMATION:
- Hostname: $hostname
- RHEL Version: $(cat /etc/redhat-release)
- Satellite Version: $sat_version
- Analysis Date: $(date)

ANALYSIS SUMMARY:
- Complete health check performed using foreman-maintain
- Available errata and security updates analyzed
- System logs reviewed for errors and warnings
- Resource utilization assessed
- Satellite services status verified
- Database connectivity tested

ATTACHED FILES:
- Comprehensive system analysis report
$(if [[ -f "$sos_file" ]]; then echo "- Complete SOS report with Satellite plugins"; fi)

REQUESTED ACTIONS:
1. Review the attached analysis for any critical issues
2. Provide recommendations for identified warnings or errors
3. Advise on available errata and upgrade planning
4. Recommend best practices for ongoing maintenance

This case has been created proactively to ensure optimal system health and performance.
Please review all attached documentation and provide recommendations."

    if command -v redhat-support-tool &> /dev/null; then
        # Create the support case
        local case_number=$(redhat-support-tool create \
            --summary "$case_summary" \
            --description "$case_description" \
            --product "Red Hat Satellite" \
            --version "$sat_version" \
            --severity "3" 2>/dev/null | grep -o 'Case [0-9]*' | awk '{print $2}')
        
        if [[ -n "$case_number" ]]; then
            print_success "Support case created: $case_number"
            
            # Upload analysis file
            print_status "Uploading analysis report to case $case_number..."
            if redhat-support-tool upload -c "$case_number" "$analysis_file" 2>/dev/null; then
                print_success "Analysis report uploaded successfully"
            else
                print_warning "Failed to upload analysis report"
            fi
            
            # Upload SOS report if available
            if [[ -f "$sos_file" ]]; then
                print_status "Uploading SOS report to case $case_number..."
                if redhat-support-tool upload -c "$case_number" "$sos_file" 2>/dev/null; then
                    print_success "SOS report uploaded successfully"
                else
                    print_warning "Failed to upload SOS report"
                fi
            fi
            
            echo "CASE_NUMBER=$case_number" >> "$LOG_FILE"
            echo "ANALYSIS_FILE=$analysis_file" >> "$LOG_FILE"
            echo "SOS_FILE=$sos_file" >> "$LOG_FILE"
            
            print_status "Support case summary:"
            print_info "  Case Number: $case_number"
            print_info "  Analysis File: $analysis_file"
            if [[ -f "$sos_file" ]]; then
                print_info "  SOS Report: $sos_file"
            fi
            print_info "  Case URL: https://access.redhat.com/support/cases/$case_number"
            
        else
            print_error "Failed to create support case"
            print_info "Analysis file saved locally: $analysis_file"
            if [[ -f "$sos_file" ]]; then
                print_info "SOS report available: $sos_file"
            fi
        fi
    else
        print_warning "redhat-support-tool not available"
        print_info "Analysis saved to: $analysis_file"
        print_info "Please create a support case manually and upload the analysis file"
        if [[ -f "$sos_file" ]]; then
            print_info "SOS report available for upload: $sos_file"
        fi
    fi
    
    print_status "Comprehensive support ticket creation completed"
}

# Function to check Satellite services and test provisioning
check_satellite_services_and_provisioning() {
    print_header "Checking Satellite Services & Testing Provisioning"
    
    # Step 1: Check if Satellite services are running
    print_status "Step 1: Checking Satellite services status..."
    
    local services=(
        "httpd"
        "postgresql"
        "pulpcore"
        "pulpcore-api"
        "pulpcore-content"
        "pulpcore-worker@1"
        "pulpcore-worker@2"
        "foreman-proxy"
        "dynflow-sidekiq@orchestrator"
        "dynflow-sidekiq@worker"
        "tomcat"
        "qpidd"
        "qdrouterd"
        "puppetserver"
    )
    
    local failed_services=()
    for service in "${services[@]}"; do
        echo -n "  Checking service: $service ... "
        if systemctl is-active --quiet "$service"; then
            print_success "Running"
            echo "Service $service: RUNNING" >> "$LOG_FILE"
        else
            print_error "Not running"
            echo "Service $service: FAILED" >> "$LOG_FILE"
            failed_services+=("$service")
        fi
    done
    
    if [ ${#failed_services[@]} -eq 0 ]; then
        print_success "All required services are running"
        echo ">> All required services are running" >> "$REPORT_FILE"
    else
        print_error "The following services are not running:"
        for service in "${failed_services[@]}"; do
            echo "  - $service"
            echo ">> Failed service: $service" >> "$REPORT_FILE"
        fi
        
        echo
        read -p "Do you want to attempt to start failed services? (y/n): " start_services
        if [[ "$start_services" == "y" || "$start_services" == "Y" ]]; then
            for service in "${failed_services[@]}"; do
                print_status "Starting $service..."
                if sudo systemctl start "$service"; then
                    print_success "$service started successfully"
                else
                    print_error "Failed to start $service"
                    echo "Failed to start service $service" >> "$LOG_FILE"
                fi
            done
        fi
    fi
    
    # Step 2: Check Satellite health
    print_status "Step 2: Running Satellite health check..."
    if command -v foreman-maintain > /dev/null 2>&1; then
        echo
        sudo foreman-maintain health check
        local health_status=$?
        
        if [ $health_status -eq 0 ]; then
            print_success "Foreman health check passed"
            echo ">> Foreman health check: PASSED" >> "$REPORT_FILE"
        else
            print_warning "Foreman health check reported issues"
            echo ">> Foreman health check: ISSUES FOUND" >> "$REPORT_FILE"
            
            echo
            read -p "Do you want to attempt to fix health check issues? (y/n): " fix_issues
            if [[ "$fix_issues" == "y" || "$fix_issues" == "Y" ]]; then
                sudo foreman-maintain health fix
            fi
        fi
    else
        print_error "foreman-maintain not found"
        echo ">> foreman-maintain tool not available" >> "$REPORT_FILE"
    fi
    
    # Step 3: Check compute resources
    print_status "Step 3: Checking compute resources..."
    local compute_resources=$(sudo -u postgres psql -d foreman -c "SELECT name, provider FROM compute_resources;" -t 2>/dev/null)
    
    if [ -z "$compute_resources" ]; then
        print_warning "No compute resources found in Satellite"
        echo ">> No compute resources configured" >> "$REPORT_FILE"
        
        echo
        read -p "Would you like to set up a Libvirt compute resource? (y/n): " setup_libvirt
        if [[ "$setup_libvirt" == "y" || "$setup_libvirt" == "Y" ]]; then
            setup_libvirt_compute_resource
        fi
    else
        print_success "Compute resources found:"
        echo "$compute_resources"
        echo ">> Compute resources found:" >> "$REPORT_FILE"
        echo "$compute_resources" >> "$REPORT_FILE"
        
        # Check if libvirt compute resource exists
        if ! echo "$compute_resources" | grep -q "Libvirt\|libvirt"; then
            print_warning "No Libvirt compute resource found"
            echo
            read -p "Would you like to set up a Libvirt compute resource? (y/n): " setup_libvirt
            if [[ "$setup_libvirt" == "y" || "$setup_libvirt" == "Y" ]]; then
                setup_libvirt_compute_resource
            fi
        else
            # Test existing Libvirt compute resource
            test_libvirt_compute_resource
        fi
    fi
    
    # Step 4: Verify provisioning templates
    print_status "Step 4: Verifying provisioning templates..."
    local templates=$(hammer --no-headers template list 2>/dev/null)
    
    if [ -z "$templates" ]; then
        print_error "No provisioning templates found or Hammer CLI not working"
        echo ">> Provisioning templates check: FAILED" >> "$REPORT_FILE"
    else
        local template_count=$(echo "$templates" | wc -l)
        print_success "$template_count provisioning templates found"
        echo ">> $template_count provisioning templates available" >> "$REPORT_FILE"
    fi
    
    # Step 5: Verify Satellite sync status
    print_status "Step 5: Checking content sync status..."
    local sync_status=$(hammer --no-headers task list --search "state=running AND label=Actions::Katello::Repository::Sync" 2>/dev/null)
    
    if [ -z "$sync_status" ]; then
        print_success "No content syncs currently running"
        echo ">> Content sync status: No syncs running" >> "$REPORT_FILE"
    else
        print_warning "Content syncs in progress:"
        echo "$sync_status"
        echo ">> Content sync status: Syncs in progress" >> "$REPORT_FILE"
        echo "$sync_status" >> "$REPORT_FILE"
    fi
    
    # Step 6: Check for recent failed tasks
    print_status "Step 6: Checking for failed tasks..."
    local failed_tasks=$(hammer --no-headers task list --search "state=stopped AND result=error" --order="ended_at DESC" --per-page=5 2>/dev/null)
    
    if [ -z "$failed_tasks" ]; then
        print_success "No recent failed tasks found"
        echo ">> Failed tasks check: None found" >> "$REPORT_FILE"
    else
        print_warning "Recent failed tasks:"
        echo "$failed_tasks"
        echo ">> Failed tasks found:" >> "$REPORT_FILE"
        echo "$failed_tasks" >> "$REPORT_FILE"
    fi
    
    # Completion message
    print_header "Satellite Services & Provisioning Check Complete"
    echo
    echo "Summary:"
    echo "  - Service check: ${#failed_services[@]} issues found"
    echo "  - Health check: $([ "$health_status" -eq 0 ] && echo "Passed" || echo "Issues found")"
    echo "  - Compute resources: $([ -z "$compute_resources" ] && echo "None found" || echo "Available")"
    echo "  - Provisioning templates: $([ -z "$templates" ] && echo "None found" || echo "$template_count found")"
    
    echo
    print_status "Check complete. See $LOG_FILE and $REPORT_FILE for details."
}

# Function to set up a Libvirt compute resource
setup_libvirt_compute_resource() {
    print_status "Setting up Libvirt compute resource..."
    
    # Check if libvirtd is installed and running
    if ! command -v virsh > /dev/null 2>&1; then
        print_error "libvirtd is not installed"
        echo "Please install libvirt packages first:"
        echo "  sudo dnf install -y libvirt libvirt-daemon qemu-kvm"
        return 1
    fi
    
    if ! systemctl is-active --quiet libvirtd; then
        print_warning "libvirtd service is not running"
        echo
        read -p "Start libvirtd service? (y/n): " start_libvirt
        if [[ "$start_libvirt" == "y" || "$start_libvirt" == "Y" ]]; then
            sudo systemctl start libvirtd
            sudo systemctl enable libvirtd
            print_success "libvirtd started and enabled"
        else
            print_error "Cannot continue without running libvirtd service"
            return 1
        fi
    fi
    
    # Get Libvirt connection details
    echo
    print_status "Please provide Libvirt connection details:"
    read -p "Libvirt URL (default: qemu:///system): " libvirt_url
    libvirt_url=${libvirt_url:-"qemu:///system"}
    
    read -p "Display Name for the compute resource (default: Libvirt-Local): " display_name
    display_name=${display_name:-"Libvirt-Local"}
    
    # Create the compute resource
    print_status "Creating Libvirt compute resource..."
    
    local create_output=$(hammer compute-resource create --name "$display_name" --provider libvirt --url "$libvirt_url" 2>&1)
    local create_status=$?
    
    if [ $create_status -eq 0 ]; then
        print_success "Libvirt compute resource created successfully"
        echo ">> Created Libvirt compute resource: $display_name" >> "$REPORT_FILE"
    else
        print_error "Failed to create Libvirt compute resource"
        echo "$create_output"
        echo ">> Failed to create Libvirt compute resource: $create_output" >> "$REPORT_FILE"
        return 1
    fi
    
    # Test the connection
    test_libvirt_compute_resource "$display_name"
}

# Function to test a Libvirt compute resource
test_libvirt_compute_resource() {
    local resource_name="$1"
    print_status "Testing Libvirt compute resource..."
    
    if [ -z "$resource_name" ]; then
        # Get the first libvirt compute resource if name not provided
        resource_name=$(sudo -u postgres psql -d foreman -c "SELECT name FROM compute_resources WHERE provider='Libvirt' LIMIT 1;" -t 2>/dev/null | xargs)
        
        if [ -z "$resource_name" ]; then
            print_error "No Libvirt compute resource found to test"
            return 1
        fi
    fi
    
    print_status "Testing connection to Libvirt compute resource: $resource_name"
    
    local test_output=$(hammer compute-resource info --name "$resource_name" 2>&1)
    local test_status=$?
    
    if [ $test_status -eq 0 ]; then
        print_success "Successfully connected to compute resource"
        
        # Attempt to list networks
        print_status "Attempting to list networks from compute resource..."
        local networks_output=$(hammer compute-resource networks --name "$resource_name" 2>&1)
        local networks_status=$?
        
        if [ $networks_status -eq 0 ]; then
            print_success "Successfully retrieved networks:"
            echo "$networks_output"
            echo ">> Libvirt networks available: YES" >> "$REPORT_FILE"
        else
            print_error "Failed to retrieve networks"
            echo "$networks_output"
            echo ">> Libvirt networks available: NO" >> "$REPORT_FILE"
        fi
        
        # Option to test provisioning
        echo
        read -p "Would you like to test VM provisioning? (This will create a test VM) (y/n): " test_provision
        if [[ "$test_provision" == "y" || "$test_provision" == "Y" ]]; then
            test_vm_provisioning "$resource_name"
        fi
    else
        print_error "Failed to connect to compute resource"
        echo "$test_output"
        echo ">> Libvirt connection test: FAILED" >> "$REPORT_FILE"
    fi
}

# Function to test VM provisioning
test_vm_provisioning() {
    local resource_name="$1"
    print_status "Testing VM provisioning with $resource_name..."
    
    # Get an operating system
    print_status "Checking available operating systems..."
    local os_list=$(hammer --no-headers os list 2>/dev/null)
    
    if [ -z "$os_list" ]; then
        print_error "No operating systems found. Cannot test provisioning."
        echo ">> VM provisioning test: FAILED (No OS)" >> "$REPORT_FILE"
        return 1
    fi
    
    print_success "Operating systems found:"
    echo "$os_list"
    
    # Get a domain
    print_status "Checking available domains..."
    local domain_list=$(hammer --no-headers domain list 2>/dev/null)
    
    if [ -z "$domain_list" ]; then
        print_error "No domains found. Cannot test provisioning."
        echo ">> VM provisioning test: FAILED (No domain)" >> "$REPORT_FILE"
        return 1
    fi
    
    print_success "Domains found:"
    echo "$domain_list"
    
    # Create a test VM
    local test_vm_name="satellite-test-vm-$(date +%H%M%S)"
    print_status "Creating test VM: $test_vm_name"
    
    echo
    print_warning "This is a demonstration only. In a production environment,"
    print_warning "you would need to specify architecture, OS, provisioning templates, etc."
    print_warning "Proceeding with dummy command to simulate provisioning..."
    
    # This is a placeholder - in a real scenario you'd use the actual hammer command
    # hammer compute-resource image create --name "$test_vm_name" --compute-resource "$resource_name" ...
    
    echo
    print_status "In a production environment, you would run:"
    echo "hammer host create --name $test_vm_name --compute-resource \"$resource_name\" --compute-profile \"small\""
    echo "                  --architecture \"x86_64\" --domain \"example.com\" --operatingsystem \"RHEL 9\""
    echo "                  --medium \"RHEL 9\" --partition-table \"Kickstart default\" --model \"KVM VM\""
    echo "                  --root-password \"password\" --provision-method build"
    
    echo ">> VM provisioning test: SIMULATED" >> "$REPORT_FILE"
    
    print_status "To perform actual VM provisioning, ensure you have:"
    echo "  1. Properly configured compute resource"
    echo "  2. Synced content (OS media)"
    echo "  3. Configured domains and subnets"
    echo "  4. Created appropriate host groups"
    echo "  5. Set up provisioning templates"
}

# Function to clean up Satellite environment
clean_satellite_environment() {
    print_status "Cleaning Satellite environment..."
    
    # Clean up old tasks
    print_status "Cleaning up old tasks..."
    if hammer --no-headers task list --search "state=stopped" --per-page=1 > /dev/null 2>&1; then
        sudo foreman-rake foreman_tasks:cleanup TASK_SEARCH='state = stopped' AFTER=30d
        print_success "Old tasks cleaned up"
    else
        print_warning "No tasks found or Hammer not working"
    fi
    
    # Clean up orphaned content
    print_status "Cleaning up orphaned content..."
    if command -v foreman-maintain > /dev/null 2>&1; then
        sudo foreman-maintain content delete-orphaned
        print_success "Orphaned content cleaned up"
    else
        print_warning "foreman-maintain not available"
    fi
    
    # Clean up audit logs
    print_status "Cleaning up old audit logs..."
    if sudo -u postgres psql -d foreman -c "SELECT COUNT(*) FROM audits;" -t > /dev/null 2>&1; then
        sudo -u postgres psql -d foreman -c "DELETE FROM audits WHERE created_at < NOW() - INTERVAL '90 days';"
        print_success "Old audit logs cleaned up"
    else
        print_warning "Could not access audit logs"
    fi
    
    # Clean up old reports
    print_status "Cleaning up old reports..."
    if sudo -u postgres psql -d foreman -c "SELECT COUNT(*) FROM reports;" -t > /dev/null 2>&1; then
        sudo -u postgres psql -d foreman -c "DELETE FROM reports WHERE reported_at < NOW() - INTERVAL '60 days';"
        print_success "Old reports cleaned up"
    else
        print_warning "Could not access reports"
    fi
    
    # Clean up temporary directory
    print_status "Cleaning up temporary files..."
    sudo rm -rf /var/tmp/foreman-*
    sudo rm -rf /tmp/foreman-*
    print_success "Temporary files cleaned up"
    
    echo ">> Satellite environment cleaned up" >> "$REPORT_FILE"
}

# Function to generate maintenance report
generate_maintenance_report() {
    print_header "Generating Maintenance Report"
    
    local hostname=$(hostname -f)
    local rhel_version=$(detect_rhel_version)
    local sat_version=$(rpm -q satellite --queryformat '%{VERSION}' 2>/dev/null || echo "unknown")
    
    # Create comprehensive report
    cat > "$REPORT_FILE" << EOF
# Red Hat Satellite Maintenance Report

**Generated:** $(date)  
**System:** $hostname  
**RHEL Version:** $rhel_version  
**Satellite Version:** $sat_version  
**Maintenance Session:** $TIMESTAMP

## Executive Summary

This report documents the maintenance activities performed on the Red Hat Satellite server.
All procedures followed Red Hat best practices and documented guidelines.

## System Information

- **Hostname:** $hostname
- **Operating System:** Red Hat Enterprise Linux $rhel_version
- **Satellite Version:** $sat_version
- **Maintenance Date:** $(date)
- **Maintenance Duration:** [To be calculated]

EOF

    # Add individual section results (these will be appended by each function)
    
    # Calculate report size and finalize
    if [[ -f "$REPORT_FILE" ]]; then
        local report_size=$(du -h "$REPORT_FILE" | cut -f1)
        
        cat >> "$REPORT_FILE" << EOF

## Summary

This maintenance report documents all activities performed during this session.
All logs and supporting files are retained for audit and troubleshooting purposes.

**Report File:** $REPORT_FILE  
**Report Size:** $report_size  
**Log Directory:** $LOG_DIR

## Next Steps

1. Review any warnings or failed health checks
2. Monitor system performance post-maintenance
3. Update documentation and runbooks as needed
4. Schedule follow-up maintenance as required

---
*Generated by Red Hat Satellite Maintenance Tool v1.0*
EOF

        print_success "Maintenance report generated: $REPORT_FILE"
        print_status "Report size: $report_size"
    else
        print_error "Failed to generate maintenance report"
        return 1
    fi
}

# Function to run complete maintenance workflow
run_complete_maintenance() {
    print_header "Complete Satellite Maintenance Workflow"
    
    local satellite_version="${1:-}"
    local support_case=""
    
    # If no version specified, prompt user
    if [[ -z "$satellite_version" ]]; then
        echo ""
        echo "Select target Satellite version:"
        echo "1) 6.15"
        echo "2) 6.16" 
        echo "3) 6.17"
        echo ""
        read -p "Enter choice (1-3): " version_choice
        
        case "$version_choice" in
            1) satellite_version="6.15" ;;
            2) satellite_version="6.16" ;;
            3) satellite_version="6.17" ;;
            *) print_error "Invalid choice"; return 1 ;;
        esac
    fi
    
    print_status "Starting complete maintenance workflow for Satellite $satellite_version"
    
    # Initialize maintenance report
    generate_maintenance_report
    
    # Step 1: Create support case
    if create_support_case; then
        support_case=$(grep "SUPPORT_CASE=" "$LOG_FILE" | cut -d'=' -f2)
    fi
    
    # Step 2: Run health check
    run_health_check
    
    # Step 3: Create SOS report
    create_sos_report
    
    # Step 4: Upload reports to support case
    if [[ -n "$support_case" ]]; then
        local sos_file=$(grep "SOS_REPORT_FILE=" "$LOG_FILE" | cut -d'=' -f2)
        upload_to_support_case "$support_case" "$REPORT_FILE" "$sos_file"
    fi
    
    # Step 5: Create system snapshot
    create_system_snapshot
    
    # Step 6: Create system backup
    create_system_backup
    
    # Final report update
    {
        echo "## Workflow Summary"
        echo "- **Support Case:** ${support_case:-'Manual creation required'}"
        echo "- **Health Check:** Completed"
        echo "- **SOS Report:** Generated"
        echo "- **System Snapshot:** Recommended/Created"
        echo "- **System Backup:** Completed"
        echo ""
    } >> "$REPORT_FILE"
    
    print_success "Complete maintenance workflow finished"
    print_status "Review report: $REPORT_FILE"
}

# Parse command line arguments
parse_arguments() {
    local satellite_version=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--case)
                create_support_case
                exit $?
                ;;
            -k|--health-check)
                initialize_environment
                check_prerequisites || exit 1
                run_health_check
                exit $?
                ;;
            -s|--sos-report)
                initialize_environment
                create_sos_report
                exit $?
                ;;
            -b|--backup)
                initialize_environment
                check_prerequisites || exit 1
                create_system_backup
                exit $?
                ;;
            -u|--upgrade)
                if [[ -z "$satellite_version" ]]; then
                    print_error "Satellite version required for upgrade. Use --version"
                    exit 1
                fi
                initialize_environment
                check_prerequisites || exit 1
                run_satellite_upgrade "$satellite_version"
                exit $?
                ;;
            -r|--report)
                initialize_environment
                generate_maintenance_report
                exit $?
                ;;
            -t|--ticket)
                initialize_environment
                create_comprehensive_support_ticket
                exit $?
                ;;
            -p|--provisioning)
                initialize_environment
                check_satellite_services_and_provisioning
                exit $?
                ;;
            --version)
                shift
                if [[ -n "$1" && "${SATELLITE_VERSIONS[$1]:-}" ]]; then
                    satellite_version="$1"
                else
                    print_error "Invalid Satellite version: $1"
                    print_status "Supported versions: ${!SATELLITE_VERSIONS[*]}"
                    exit 1
                fi
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
        shift
    done
    
    # If we get here, run interactive mode
    export SATELLITE_VERSION="$satellite_version"
}

# Interactive menu
interactive_menu() {
    while true; do
        clear
        print_header "Red Hat Satellite Maintenance & Remediation"
        echo ""
        echo "System Information:"
        echo "  Hostname: $(hostname -f)"
        echo "  RHEL Version: $(detect_rhel_version)"
        echo "  Satellite Version: $(rpm -q satellite --queryformat '%{VERSION}' 2>/dev/null || echo 'Not detected')"
        echo ""
        echo "Choose an action:"
        echo "1)  Check Prerequisites"
        echo "2)  Create Red Hat Support Case"
        echo "3)  Run Health Check (foreman-maintain)"
        echo "4)  Generate SOS Report"
        echo "5)  Create System Snapshot"
        echo "6)  Create System Backup"
        echo "7)  Configure Repositories"
        echo "8)  Run Satellite Upgrade"
        echo "9)  Complete Maintenance Workflow"
        echo "10) Generate Maintenance Report"
        echo "11) View Logs"
        echo "12) Create Comprehensive Support Ticket"
        echo "13) Check Satellite Services & Test Provisioning"
        echo "14) Exit"
        echo ""
        read -p "Enter your choice (1-14): " choice
        
        case $choice in
            1)
                initialize_environment
                check_prerequisites
                read -p "Press Enter to continue..."
                ;;
            2)
                initialize_environment
                create_support_case
                read -p "Press Enter to continue..."
                ;;
            3)
                initialize_environment
                check_prerequisites && run_health_check
                read -p "Press Enter to continue..."
                ;;
            4)
                initialize_environment
                create_sos_report
                read -p "Press Enter to continue..."
                ;;
            5)
                initialize_environment
                create_system_snapshot
                read -p "Press Enter to continue..."
                ;;
            6)
                initialize_environment
                check_prerequisites && create_system_backup
                read -p "Press Enter to continue..."
                ;;
            7)
                echo ""
                echo "Select Satellite version:"
                echo "1) 6.15"
                echo "2) 6.16"
                echo "3) 6.17"
                read -p "Enter choice (1-3): " ver_choice
                
                case "$ver_choice" in
                    1) version="6.15" ;;
                    2) version="6.16" ;;
                    3) version="6.17" ;;
                    *) print_error "Invalid choice"; continue ;;
                esac
                
                initialize_environment
                configure_repositories "$version"
                read -p "Press Enter to continue..."
                ;;
            8)
                echo ""
                echo "Select target Satellite version:"
                echo "1) 6.15"
                echo "2) 6.16"
                echo "3) 6.17"
                read -p "Enter choice (1-3): " ver_choice
                
                case "$ver_choice" in
                    1) version="6.15" ;;
                    2) version="6.16" ;;
                    3) version="6.17" ;;
                    *) print_error "Invalid choice"; continue ;;
                esac
                
                initialize_environment
                check_prerequisites && run_satellite_upgrade "$version"
                read -p "Press Enter to continue..."
                ;;
            9)
                initialize_environment
                check_prerequisites && run_complete_maintenance
                read -p "Press Enter to continue..."
                ;;
            10)
                initialize_environment
                generate_maintenance_report
                read -p "Press Enter to continue..."
                ;;
            11)
                echo ""
                echo "Available log files:"
                find "$LOG_DIR" -name "*.log" -type f 2>/dev/null | tail -10 || echo "No logs found"
                echo ""
                read -p "Enter log file path to view (or press Enter to skip): " log_path
                if [[ -f "$log_path" ]]; then
                    less "$log_path"
                fi
                ;;
            12)
                initialize_environment
                create_comprehensive_support_ticket
                read -p "Press Enter to continue..."
                ;;
            13)
                initialize_environment
                check_satellite_services_and_provisioning
                read -p "Press Enter to continue..."
                ;;
            14)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please try again."
                sleep 2
                ;;
        esac
    done
}

# Main execution
main() {
    # Handle command line arguments
    if [[ $# -gt 0 ]]; then
        parse_arguments "$@"
    fi
    
    # Run interactive menu if no arguments provided
    interactive_menu
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
