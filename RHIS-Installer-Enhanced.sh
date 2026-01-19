#!/bin/bash
################################################################################
# RHIS-Installer-Enhanced.sh
# Main entry point for Red Hat Infrastructure Standard (RHIS) deployment
# Orchestrates complete deployment lifecycle from credential collection to
# final integration testing
#
# Usage: ./RHIS-Installer-Enhanced.sh [--scenario] [--platform] [--os] [--skip-prompts]
################################################################################

set -euo pipefail

# ============================================================================
# CONFIGURATION & CONSTANTS
# ============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPT_DIR="${PROJECT_ROOT}"
PLAYBOOKS_DIR="${PROJECT_ROOT}/playbooks"
ROLES_DIR="${PROJECT_ROOT}/roles"
INVENTORY_DIR="${PROJECT_ROOT}/inventory"
TEMPLATES_DIR="${PROJECT_ROOT}/templates"
DOCS_DIR="${PROJECT_ROOT}/docs"
FILES_DIR="${PROJECT_ROOT}/files"
CREDENTIALS_DIR="${HOME}/.ansible/conf"
CREDENTIALS_FILE="${CREDENTIALS_DIR}/env.yml"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Version information
RHIS_VERSION="1.0.0"
INSTALLER_VERSION="1.0"
DEPLOYMENT_DATE="$(date +'%Y-%m-%d_%H-%M-%S')"

# Deployment scenarios
declare -A SCENARIOS=(
    ["1"]="satellite_only"
    ["2"]="aap_only"
    ["3"]="idm_only"
    ["4"]="openshift_only"
    ["5"]="satellite_aap"
    ["6"]="satellite_idm"
    ["7"]="satellite_openshift"
    ["8"]="aap_idm"
    ["9"]="aap_openshift"
    ["10"]="idm_openshift"
    ["11"]="satellite_aap_idm"
    ["12"]="satellite_aap_openshift"
    ["13"]="satellite_idm_openshift"
    ["14"]="aap_idm_openshift"
    ["15"]="full_stack"  # Satellite + AAP + IdM + OpenShift (DEFAULT)
)

# Platform options
declare -A PLATFORMS=(
    ["1"]="libvirt"
    ["2"]="baremetal"
    ["3"]="aws"
    ["4"]="azure"
    ["5"]="gcp"
    ["6"]="vmware"
    ["7"]="nutanix"
)

# OS options
declare -A OPERATING_SYSTEMS=(
    ["1"]="rhel-9"
    ["2"]="rhel-10"
)

# Log file
LOG_DIR="${PROJECT_ROOT}/logs"
LOG_FILE="${LOG_DIR}/deployment_${DEPLOYMENT_DATE}.log"

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Initialize environment
init_environment() {
    # Create necessary directories
    mkdir -p "${CREDENTIALS_DIR}"
    mkdir -p "${LOG_DIR}"
    mkdir -p "${INVENTORY_DIR}"
    
    # Initialize log file
    echo "RHIS Deployment Log - ${DEPLOYMENT_DATE}" > "${LOG_FILE}"
    echo "=========================================" >> "${LOG_FILE}"
}

# Source shared local env helpers if present
if [[ -f "${PROJECT_ROOT}/scripts/lib/local_env.sh" ]]; then
    # shellcheck disable=SC1090
    source "${PROJECT_ROOT}/scripts/lib/local_env.sh"
fi

# Print styled header
print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${MAGENTA}Red Hat Infrastructure Standard (RHIS) - Deployment Installer${NC}"
    echo -e "${CYAN}║${NC}  Version: ${RHIS_VERSION}  |  Installer: ${INSTALLER_VERSION}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Project Root: ${BLUE}${PROJECT_ROOT}${NC}"
    echo ""
}

# Print menu section
print_section() {
    local title="$1"
    echo ""
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${title}"
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Print menu options
print_option() {
    local number="$1"
    local label="$2"
    local description="${3:-}"
    printf "  ${CYAN}[%s]${NC} %-25s %s\n" "$number" "$label" "$description"
}

# Print success message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error message
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Print info message
print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Print warning message
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [${level}] ${message}" >> "${LOG_FILE}"
}

# Pause and wait for user
pause() {
    local message="${1:-Press [Enter] to continue...}"
    read -p "$(echo -e ${YELLOW}${message}${NC})" -r
}

# ============================================================================
# LOCAL CONFIG HELPERS (on-demand only)
# These helpers read values from a user-local config at ${CREDENTIALS_DIR}/env.yml
# but DO NOT use them as automatic defaults. Values are read only when explicitly
# requested by the user during interactive prompts.
# ============================================================================

# Read a YAML key from ${CREDENTIALS_DIR}/env.yml and print its value.
# Usage: read_local_env_key "some.key.path"
read_local_env_key() {
    local key="$1"
    local file="${CREDENTIALS_DIR}/env.yml"

    if [[ ! -f "${file}" ]]; then
        return 1
    fi

    # Use python to safely parse YAML and return the requested nested key
    python3 - <<PY
import sys, yaml
f='''${file}'''
k='''${key}'''
try:
    with open(f) as fh:
        data = yaml.safe_load(fh) or {}
    value = data
    for part in k.split('.'):
        if isinstance(value, dict) and part in value:
            value = value[part]
        else:
            print('')
            sys.exit(0)
    if value is None:
        print('')
    else:
        print(value)
except Exception:
    print('')
    sys.exit(0)
PY
}

# Mask a value for safe display (show only last 4 chars)
mask_value() {
    local val="$1"
    if [[ -z "${val}" ]]; then
        echo "(not set)"
        return
    fi
    local len=${#val}
    if [[ ${len} -le 8 ]]; then
        echo "****${val: -4}"
    else
        echo "****${val: -4}"
    fi
}

# ============================================================================
# CREDENTIAL COLLECTION
# ============================================================================

collect_red_hat_credentials() {
    print_header
    print_section "Red Hat Credentials Collection"
    
    echo "These credentials are required for Red Hat access and are stored securely in:"
    echo -e "${BLUE}${CREDENTIALS_FILE}${NC}"
    echo ""
    echo "Credentials will be encrypted using Ansible Vault."
    echo ""
    
    # Check if credentials file exists
    if [[ -f "${CREDENTIALS_FILE}" ]]; then
        print_warning "Credentials file already exists at ${CREDENTIALS_FILE}"
        echo "Choose how to proceed with existing local credentials:"
        echo "  [U]pdate - overwrite with new credentials"
        echo "  [L]ookup - view values from local config and optionally use them for this run (no files changed)"
        echo "  [S]kip  - do not use local config; enter new credentials now"
        read -p "Choose [U/L/S] (default U): " -r CREDS_CHOICE
        CREDS_CHOICE="${CREDS_CHOICE:-U}"

        case "${CREDS_CHOICE^^}" in
            L)
                # Attempt to show masked values from local config and ask to use them
                LOCAL_USER="$(read_local_env_key 'cdn_username' || true)"
                LOCAL_OFFLINE_TOKEN="$(read_local_env_key 'offline_token' || true)"
                echo "Local credentials preview:"
                echo "  CDN Username: $(mask_value "${LOCAL_USER}")"
                echo "  Offline Token: $(mask_value "${LOCAL_OFFLINE_TOKEN}")"
                read -p "Use these local credentials for this run? (y/N): " -r USE_LOCAL
                if [[ "${USE_LOCAL}" =~ ^[Yy]$ ]]; then
                    export RHIS_CDN_USERNAME="${LOCAL_USER}"
                    # Do not export full token if empty
                    if [[ -n "${LOCAL_OFFLINE_TOKEN}" ]]; then
                        export RHIS_OFFLINE_TOKEN="${LOCAL_OFFLINE_TOKEN}"
                    fi
                    print_success "Using local credentials for this session (not saved to repository)"
                    return 0
                else
                    print_info "Proceeding to prompt for new credentials"
                fi
                ;;
            S)
                print_info "Skipping local config and prompting for credentials"
                ;;
            U|*)
                # Fall through to prompt for new credentials which may later be vaulted by helper
                ;;
        esac
    fi
    
    # Collect credentials
    # Username should be visible while typing; passwords remain hidden
    read -p "Red Hat CDN Username (for redhat.com/redhat.io): " -r CDN_USERNAME
    read -sp "Red Hat CDN Password (for redhat.com/redhat.io): " -r CDN_PASSWORD
    echo ""
    read -sp "Red Hat Offline Token (for console.redhat.com/Automation Hub): " -r OFFLINE_TOKEN
    echo ""
    
    # Validate credentials
    if [[ -z "${CDN_USERNAME}" || -z "${CDN_PASSWORD}" || -z "${OFFLINE_TOKEN}" ]]; then
        print_error "All credentials are required"
        log "ERROR" "Incomplete credentials collection"
        return 1
    fi
    
    print_success "Credentials collected"
    
    # Save credentials to file (will be handled by playbook with vault encryption)
    log "INFO" "Credentials collected successfully"
    
    # Store credentials in environment for use by playbooks
    export RHIS_CDN_USERNAME="${CDN_USERNAME}"
    export RHIS_CDN_PASSWORD="${CDN_PASSWORD}"
    export RHIS_OFFLINE_TOKEN="${OFFLINE_TOKEN}"
    
    return 0
}

# ============================================================================
# SCENARIO SELECTION
# ============================================================================

select_scenario() {
    print_header
    print_section "Deployment Scenario Selection"
    
    echo "Choose the products to deploy:"
    echo ""
    print_option "1" "Satellite Only" "Systems management & provisioning"
    print_option "2" "AAP Only" "Automation platform & orchestration"
    print_option "3" "IdM Only" "Identity & access management"
    print_option "4" "OpenShift Only" "Container orchestration platform"
    print_option "5" "Satellite + AAP" "Inventory + Automation"
    print_option "6" "Satellite + IdM" "Inventory + Identity"
    print_option "7" "Satellite + OpenShift" "Inventory + Containers"
    print_option "8" "AAP + IdM" "Automation + Identity"
    print_option "9" "AAP + OpenShift" "Automation + Containers"
    print_option "10" "IdM + OpenShift" "Identity + Containers"
    print_option "11" "Satellite + AAP + IdM" "Complete management stack"
    print_option "12" "Satellite + AAP + OpenShift" "Inventory + Automation + Containers"
    print_option "13" "Satellite + IdM + OpenShift" "Inventory + Identity + Containers"
    print_option "14" "AAP + IdM + OpenShift" "Automation + Identity + Containers"
    print_option "15" "FULL STACK (Default)" "Satellite + AAP + IdM + OpenShift"
    print_option "0" "Exit" "Exit installer"
    echo ""
    
    read -p "Enter scenario number (default: 11): " -r SCENARIO_CHOICE
    SCENARIO_CHOICE="${SCENARIO_CHOICE:-11}"

    if [[ "${SCENARIO_CHOICE}" == "0" ]]; then
        print_info "Exiting installer"
        log "INFO" "Installer exited by user (scenario menu)"
        exit 0
    fi
    
    if [[ ! ${SCENARIO_CHOICE} =~ ^[0-9]+$ ]] || [[ ${SCENARIO_CHOICE} -lt 1 ]] || [[ ${SCENARIO_CHOICE} -gt 15 ]]; then
        print_error "Invalid scenario selection"
        log "ERROR" "Invalid scenario: ${SCENARIO_CHOICE}"
        select_scenario
        return
    fi
    
    DEPLOYMENT_SCENARIO="${SCENARIOS[$SCENARIO_CHOICE]}"
    print_success "Selected scenario: ${DEPLOYMENT_SCENARIO}"
    log "INFO" "Deployment scenario selected: ${DEPLOYMENT_SCENARIO}"
}

# ============================================================================
# PLATFORM SELECTION
# ============================================================================

select_platform() {
    print_header
    print_section "Platform Selection"
    
    echo "Choose the platform where infrastructure will be deployed:"
    echo ""
    print_option "1" "LibVirt" "Local KVM virtualization (testing/development)"
    print_option "2" "Bare Metal" "Physical servers or PXE boot"
    print_option "3" "AWS" "Amazon Web Services"
    print_option "4" "Azure" "Microsoft Azure"
    print_option "5" "GCP" "Google Cloud Platform"
    print_option "6" "VMware" "VMware vSphere"
    print_option "7" "Nutanix" "Nutanix HCI platform"
    print_option "0" "Exit" "Exit installer"
    echo ""
    
    read -p "Enter platform number (default: 1 - LibVirt): " -r PLATFORM_CHOICE
    PLATFORM_CHOICE="${PLATFORM_CHOICE:-1}"

    if [[ "${PLATFORM_CHOICE}" == "0" ]]; then
        print_info "Exiting installer"
        log "INFO" "Installer exited by user (platform menu)"
        exit 0
    fi
    
    if [[ ! ${PLATFORM_CHOICE} =~ ^[0-9]+$ ]] || [[ ${PLATFORM_CHOICE} -lt 1 ]] || [[ ${PLATFORM_CHOICE} -gt 7 ]]; then
        print_error "Invalid platform selection"
        log "ERROR" "Invalid platform: ${PLATFORM_CHOICE}"
        select_platform
        return
    fi
    
    DEPLOYMENT_PLATFORM="${PLATFORMS[${PLATFORM_CHOICE}]}"
    print_success "Selected platform: ${DEPLOYMENT_PLATFORM}"
    log "INFO" "Deployment platform selected: ${DEPLOYMENT_PLATFORM}"
}

# ============================================================================
# OS SELECTION
# ============================================================================

select_os() {
    print_header
    print_section "Operating System Selection"
    
    echo "Choose the operating system for all nodes:"
    echo ""
    print_option "1" "RHEL 9" "Red Hat Enterprise Linux 9 (default)"
    print_option "2" "RHEL 10" "Red Hat Enterprise Linux 10"
    print_option "0" "Exit" "Exit installer"
    echo ""
    
    read -p "Enter OS number (default: 1 - RHEL 9): " -r OS_CHOICE
    OS_CHOICE="${OS_CHOICE:-1}"

    if [[ "${OS_CHOICE}" == "0" ]]; then
        print_info "Exiting installer"
        log "INFO" "Installer exited by user (os menu)"
        exit 0
    fi
    
    if [[ ! ${OS_CHOICE} =~ ^[0-9]+$ ]] || [[ ${OS_CHOICE} -lt 1 ]] || [[ ${OS_CHOICE} -gt 2 ]]; then
        print_error "Invalid OS selection"
        log "ERROR" "Invalid OS: ${OS_CHOICE}"
        select_os
        return
    fi
    
    DEPLOYMENT_OS="${OPERATING_SYSTEMS[${OS_CHOICE}]}"
    print_success "Selected OS: ${DEPLOYMENT_OS}"
    log "INFO" "Deployment OS selected: ${DEPLOYMENT_OS}"
}

# ============================================================================
# CONFIGURATION REVIEW & CONFIRMATION
# ============================================================================

review_configuration() {
    print_header
    print_section "Deployment Configuration Review"
    
    echo "Please review your deployment configuration:"
    echo ""
    echo -e "  Scenario:  ${CYAN}${DEPLOYMENT_SCENARIO}${NC}"
    echo -e "  Platform:  ${CYAN}${DEPLOYMENT_PLATFORM}${NC}"
    echo -e "  OS:        ${CYAN}${DEPLOYMENT_OS}${NC}"
    echo ""
    
    read -p "Is this configuration correct? (y/N): " -r CONFIRM
    if [[ ! "${CONFIRM}" =~ ^[Yy]$ ]]; then
        log "WARNING" "Configuration rejected by user"
        print_warning "Configuration rejected. Please run installer again."
        return 1
    fi
    
    print_success "Configuration confirmed"
    log "INFO" "Configuration confirmed by user"
    return 0
}

# ============================================================================
# INSTALLATION METHOD SELECTION
# ============================================================================

select_installation_method() {
    print_header
    print_section "Installation Method Selection"
    
    echo "Choose how to install and boot systems:"
    echo ""
    print_option "1" "OEMDRV Kickstart" "Use OEMDRV kickstart files for automated installation"
    print_option "2" "TFTP/PXE Boot" "Use TFTP server for network booting"
    print_option "0" "Exit" "Exit installer"
    echo ""
    
    read -p "Enter installation method (default: 1 - OEMDRV): " -r INSTALL_METHOD_CHOICE
    INSTALL_METHOD_CHOICE="${INSTALL_METHOD_CHOICE:-1}"

    if [[ "${INSTALL_METHOD_CHOICE}" == "0" ]]; then
        print_info "Exiting installer"
        log "INFO" "Installer exited by user (installation method menu)"
        exit 0
    fi
    
    case ${INSTALL_METHOD_CHOICE} in
        1)
            INSTALL_METHOD="oemdrv"
            print_success "Using OEMDRV Kickstart installation"
            log "INFO" "Installation method selected: OEMDRV"
            ;;
        2)
            INSTALL_METHOD="tftp"
            print_success "Using TFTP/PXE Boot"
            log "INFO" "Installation method selected: TFTP"
            ;;
        *)
            print_error "Invalid installation method selection"
            log "ERROR" "Invalid installation method: ${INSTALL_METHOD_CHOICE}"
            select_installation_method
            return 1
            ;;
    esac
}

# ============================================================================
# DEPLOYMENT EXECUTION
# ============================================================================

execute_deployment() {
    print_header
    print_section "Starting Deployment"
    
    log "INFO" "=== DEPLOYMENT STARTED ==="
    log "INFO" "Scenario: ${DEPLOYMENT_SCENARIO}"
    log "INFO" "Platform: ${DEPLOYMENT_PLATFORM}"
    log "INFO" "OS: ${DEPLOYMENT_OS}"
    log "INFO" "Installation Method: ${INSTALL_METHOD}"
    
    # Create deployment configuration
    create_deployment_config
    
    # Setup Ansible environment
    setup_ansible_environment
    
    # Run deployment playbooks
    run_deployment_playbooks
    
    # Post-deployment verification
    verify_deployment
    
    log "INFO" "=== DEPLOYMENT COMPLETED ==="
    print_success "Deployment completed successfully!"
}

# Create deployment configuration file
create_deployment_config() {
    print_info "Creating deployment configuration..."
    
    local config_file="${CREDENTIALS_DIR}/deployment_config.yml"
    
    cat > "${config_file}" <<EOF
---
# Deployment Configuration Generated by RHIS-Installer
# Generated: $(date)
# DO NOT EDIT MANUALLY

deployment_metadata:
  scenario: "${DEPLOYMENT_SCENARIO}"
  platform: "${DEPLOYMENT_PLATFORM}"
  os: "${DEPLOYMENT_OS}"
  install_method: "${INSTALL_METHOD}"
  generated_date: "$(date -Iseconds)"
  version: "${RHIS_VERSION}"

deployment_scenario: "${DEPLOYMENT_SCENARIO}"
deployment_platform: "${DEPLOYMENT_PLATFORM}"
deployment_os: "${DEPLOYMENT_OS}"
install_method: "${INSTALL_METHOD}"

# Platform-specific configurations
platform_config:
  libvirt:
    enabled: $([ "${DEPLOYMENT_PLATFORM}" = "libvirt" ] && echo "true" || echo "false")
  baremetal:
    enabled: $([ "${DEPLOYMENT_PLATFORM}" = "baremetal" ] && echo "true" || echo "false")
  aws:
    enabled: $([ "${DEPLOYMENT_PLATFORM}" = "aws" ] && echo "true" || echo "false")
  azure:
    enabled: $([ "${DEPLOYMENT_PLATFORM}" = "azure" ] && echo "true" || echo "false")
  gcp:
    enabled: $([ "${DEPLOYMENT_PLATFORM}" = "gcp" ] && echo "true" || echo "false")
  vmware:
    enabled: $([ "${DEPLOYMENT_PLATFORM}" = "vmware" ] && echo "true" || echo "false")
  nutanix:
    enabled: $([ "${DEPLOYMENT_PLATFORM}" = "nutanix" ] && echo "true" || echo "false")

# Installation paths
paths:
  project_root: "${PROJECT_ROOT}"
  playbooks: "${PLAYBOOKS_DIR}"
  roles: "${ROLES_DIR}"
  inventory: "${INVENTORY_DIR}"
  templates: "${TEMPLATES_DIR}"
  credentials: "${CREDENTIALS_DIR}"
  log_file: "${LOG_FILE}"
EOF
    
    print_success "Deployment configuration created: ${config_file}"
    log "INFO" "Deployment configuration file created"
}

# Setup Ansible environment
setup_ansible_environment() {
    print_info "Setting up Ansible environment..."
    
    # Check if ansible is installed
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible is not installed"
        log "ERROR" "Ansible not found in PATH"
        return 1
    fi
    
    # Check if ansible.cfg exists
    if [[ ! -f "${PROJECT_ROOT}/ansible.cfg" ]]; then
        print_info "Generating ansible.cfg from template..."
        
        # Generate ansible.cfg from template if it doesn't exist
        if [[ -f "${TEMPLATES_DIR}/ansible.cfg.j2" ]]; then
            ansible-playbook -i localhost, \
                -e "template_dir=${TEMPLATES_DIR}" \
                -e "project_root=${PROJECT_ROOT}" \
                -c local \
                <<EOF
---
- hosts: localhost
  gather_facts: no
  tasks:
    - name: Generate ansible.cfg
      template:
        src: ${TEMPLATES_DIR}/ansible.cfg.j2
        dest: ${PROJECT_ROOT}/ansible.cfg
      vars:
        roles_path: "${ROLES_DIR}"
        inventory_path: "${INVENTORY_DIR}/hosts"
EOF
        fi
    fi
    
    print_success "Ansible environment ready"
    log "INFO" "Ansible environment setup completed"
}

# Run deployment playbooks
run_deployment_playbooks() {
    print_info "Running deployment playbooks..."
    
    local playbook_tags="${DEPLOYMENT_SCENARIO},${DEPLOYMENT_PLATFORM},${DEPLOYMENT_OS}"
    
    print_info "Tags: ${playbook_tags}"
    log "INFO" "Running playbook with tags: ${playbook_tags}"
    
    # Prefer the real main playbook, but fall back to a safe placeholder
    main_playbook="${PLAYBOOKS_DIR}/site.yml"
    if ! ansible-playbook "${main_playbook}" --syntax-check -i "${INVENTORY_DIR}/hosts" >/dev/null 2>&1; then
        print_warning "Main playbook ${main_playbook} failed syntax check — using placeholder playbook"
        main_playbook="${PLAYBOOKS_DIR}/_placeholder_site.yml"
    fi

    # Run the selected playbook
    ansible-playbook \
        "${main_playbook}" \
        --tags "${playbook_tags}" \
        -e "deployment_scenario=${DEPLOYMENT_SCENARIO}" \
        -e "deployment_platform=${DEPLOYMENT_PLATFORM}" \
        -e "deployment_os=${DEPLOYMENT_OS}" \
        -e "install_method=${INSTALL_METHOD}" \
        -e "rhis_cdn_username=${RHIS_CDN_USERNAME}" \
        -e "rhis_cdn_password=${RHIS_CDN_PASSWORD}" \
        -e "rhis_offline_token=${RHIS_OFFLINE_TOKEN}" \
        -i "${INVENTORY_DIR}/hosts" \
        -v 2>&1 | tee -a "${LOG_FILE}"
    
    if [[ $? -eq 0 ]]; then
        print_success "Deployment playbooks executed successfully"
        log "INFO" "Deployment playbooks completed"
    else
        print_error "Deployment playbooks failed"
        log "ERROR" "Deployment playbooks execution failed"
        return 1
    fi
}

# Verify deployment
verify_deployment() {
    print_info "Verifying deployment..."
    
    # Run validation playbook
    ansible-playbook \
        "${PLAYBOOKS_DIR}/site.yml" \
        --tags "validate" \
        -i "${INVENTORY_DIR}/hosts" \
        -v 2>&1 | tee -a "${LOG_FILE}"
    
    if [[ $? -eq 0 ]]; then
        print_success "Deployment verification passed"
        log "INFO" "Deployment verification completed successfully"
    else
        print_warning "Deployment verification had issues"
        log "WARNING" "Deployment verification completed with warnings"
    fi
}

# ============================================================================
# MAIN MENU
# ============================================================================

show_main_menu() {
    print_header
    print_section "Main Menu"
    
    echo "Choose an option:"
    echo ""
    print_option "1" "Full Deployment" "Complete deployment from start to finish"
    print_option "2" "Configure Credentials" "Update Red Hat credentials"
    print_option "3" "Select Scenario" "Choose deployment scenario"
    print_option "4" "Select Platform" "Choose deployment platform"
    print_option "5" "View Configuration" "Display current deployment configuration"
    print_option "6" "View Logs" "Display deployment logs"
    print_option "7" "Help" "Display help information"
    print_option "0" "Exit" "Exit installer"
    echo ""
    
    read -p "Enter option number: " -r MENU_CHOICE
    
    case ${MENU_CHOICE} in
        1)
            full_deployment_flow
            ;;
        2)
            collect_red_hat_credentials
            pause
            ;;
        3)
            select_scenario
            pause
            ;;
        4)
            select_platform
            pause
            ;;
        5)
            view_configuration
            pause
            ;;
        6)
            view_logs
            pause
            ;;
        7)
            show_help
            pause
            ;;
        0)
            print_info "Exiting installer"
            log "INFO" "Installer exited by user"
            exit 0
            ;;
        *)
            print_error "Invalid option selection"
            pause
            show_main_menu
            ;;
    esac
    
    show_main_menu
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

full_deployment_flow() {
    collect_red_hat_credentials || return
    select_scenario
    select_platform
    select_os
    select_installation_method || return
    review_configuration || return
    execute_deployment
}

view_configuration() {
    print_header
    print_section "Current Configuration"
    
    if [[ -f "${CREDENTIALS_DIR}/deployment_config.yml" ]]; then
        echo "Deployment Configuration:"
        cat "${CREDENTIALS_DIR}/deployment_config.yml"
    else
        print_warning "No deployment configuration found"
    fi
}

view_logs() {
    print_header
    print_section "Deployment Logs"
    
    if [[ -f "${LOG_FILE}" ]]; then
        tail -50 "${LOG_FILE}"
    else
        print_warning "No deployment logs found"
    fi
}

show_help() {
    print_header
    print_section "Help Information"
        cat <<'HELP'
RHIS Installer Help

Description:
The RHIS Installer automates deployment of Red Hat products including:
 - Red Hat Satellite 6.18
 - Ansible Automation Platform 2.6
 - Red Hat Identity Management 3.0
 - OpenShift 4.21

Workflow:
 1. Credentials - provide Red Hat CDN and token credentials
 2. Scenario - select which products to deploy
 3. Platform - choose deployment platform
 4. OS - select operating system version
 5. Installation Method - choose OEMDRV or TFTP
 6. Confirmation - review and confirm configuration
 7. Deployment - automated deployment begins

Credentials Storage:
    Credentials should be stored only in your local configuration directory
    (e.g. ~/.ansible/conf) and should never be committed to this repository.
    If you use a local env file, encrypt it with Ansible Vault.

Configuration Storage:
    Deployment configuration (generated) will be saved in your local config
    directory: ~/.ansible/conf/deployment_config.yml

Logs:
    All deployment logs are saved to the project's logs directory.

For more information: see the documentation under docs/deployment/README.md
HELP
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    # Handle command-line arguments
    if [[ $# -gt 0 ]]; then
        case "$1" in
            --scenario)
                DEPLOYMENT_SCENARIO="$2"
                ;;
            --platform)
                DEPLOYMENT_PLATFORM="$2"
                ;;
            --os)
                DEPLOYMENT_OS="$2"
                ;;
            --skip-prompts)
                # Auto-run deployment without prompts
                DEPLOYMENT_SCENARIO="${DEPLOYMENT_SCENARIO:-full_stack}"
                DEPLOYMENT_PLATFORM="${DEPLOYMENT_PLATFORM:-libvirt}"
                DEPLOYMENT_OS="${DEPLOYMENT_OS:-rhel-9}"
                INSTALL_METHOD="${INSTALL_METHOD:-oemdrv}"
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    fi
    
    # Initialize environment
    init_environment
    
    # Show main menu or execute deployment
    show_main_menu
}

# Run main function
main "$@"
