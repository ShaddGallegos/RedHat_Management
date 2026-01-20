#!/bin/bash
################################################################################
# RHIS-installer.sh
# Main entry point for Red Hat Infrastructure Setup (RHIS) project
# Provides interactive menu for deployment, testing, and configuration
################################################################################

set -euo pipefail

# Get script directory and project root for relative paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_ROOT="$( cd "${SCRIPT_DIR}" >/dev/null 2>&1 && pwd )"

# Source initialization script for environment setup
if [[ -f "${PROJECT_ROOT}/scripts/initialization.sh" ]]; then
    source "${PROJECT_ROOT}/scripts/initialization.sh"
fi

# Source shared local env helpers (on-demand lookups only)
if [[ -f "${PROJECT_ROOT}/scripts/lib/local_env.sh" ]]; then
    # shellcheck disable=SC1090
    source "${PROJECT_ROOT}/scripts/lib/local_env.sh"
fi

# Set up directory paths for use in functions
PLAYBOOKS_DIR="${PROJECT_ROOT}/playbooks"
INVENTORY_DIR="${PROJECT_ROOT}/inventory"
ROLES_DIR="${PROJECT_ROOT}/roles"
SCRIPTS_DIR="${PROJECT_ROOT}/scripts"
DOC_DIR="${PROJECT_ROOT}/docs"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
clear_screen() {
    clear
}

print_header() {
    echo -e "${CYAN}================================================================================${NC}"
    echo -e "${CYAN}${NC} Red Hat Infrastructure Standard Adoption Model (RHIS) - Project Manager"
    echo -e "${CYAN}${NC} Project Root: ${PROJECT_ROOT}"
    echo -e "${CYAN}================================================================================${NC}"
    echo ""
}

print_menu_header() {
    local title="$1"
    echo -e "${BLUE}-----------------------------------------------------------------------${NC}"
    echo -e "${BLUE}${NC} ${title}"
    echo -e "${BLUE}-----------------------------------------------------------------------${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

print_error() {
    echo -e "${RED}[FAILED] $1${NC}"
}

print_info() {
    echo -e "${YELLOW}[INFO] $1${NC}"
}

pause_menu() {
    echo ""
    read -p "Press [Enter] to continue..."
}

# ============================================================================
# SCRIPT EXECUTION HELPERS - Execute scripts with proper PROJECT_ROOT
# ============================================================================

run_script() {
    local script_name="$1"
    shift || true
    
    # Determine script location based on name/category
    local script_path=""
    
    # Try organized script locations first
    if [[ -f "${PROJECT_ROOT}/scripts/deployment/${script_name}.sh" ]]; then
        script_path="${PROJECT_ROOT}/scripts/deployment/${script_name}.sh"
    elif [[ -f "${PROJECT_ROOT}/scripts/setup/${script_name}.sh" ]]; then
        script_path="${PROJECT_ROOT}/scripts/setup/${script_name}.sh"
    elif [[ -f "${PROJECT_ROOT}/scripts/libvirt/${script_name}.sh" ]]; then
        script_path="${PROJECT_ROOT}/scripts/libvirt/${script_name}.sh"
    elif [[ -f "${PROJECT_ROOT}/scripts/utilities/${script_name}.sh" ]]; then
        script_path="${PROJECT_ROOT}/scripts/utilities/${script_name}.sh"
    elif [[ -f "${PROJECT_ROOT}/scripts/containers/${script_name}.sh" ]]; then
        script_path="${PROJECT_ROOT}/scripts/containers/${script_name}.sh"
    elif [[ -f "${PROJECT_ROOT}/scripts/validation/${script_name}.sh" ]]; then
        script_path="${PROJECT_ROOT}/scripts/validation/${script_name}.sh"
    elif [[ -f "${PROJECT_ROOT}/scripts/${script_name}.sh" ]]; then
        # Fallback to root scripts directory for legacy scripts
        script_path="${PROJECT_ROOT}/scripts/${script_name}.sh"
    fi
    
    if [[ ! -f "$script_path" ]]; then
        print_error "Script not found: $script_name (searched in organized directories)"
        return 1
    fi
    
    # Export PROJECT_ROOT for the script
    export PROJECT_ROOT
    
    # Execute script with remaining arguments
    bash "$script_path" "$@"
}

run_playbook() {
    local playbook="$1"
    shift || true
    
    if [[ ! -f "${PROJECT_ROOT}/${playbook}" ]]; then
        print_error "Playbook not found: ${PROJECT_ROOT}/${playbook}"
        return 1
    fi
    
    cd "${PROJECT_ROOT}"
    ansible-playbook "$playbook" -i "${INVENTORY_DIR}/hosts" "$@"
}

verify_ansible() {
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible not installed or not in PATH"
        return 1
    fi
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "ansible-playbook not in PATH"
        return 1
    fi
    return 0
}

# ============================================================================
# MAIN MENU
# ============================================================================
show_main_menu() {
    clear_screen
    print_header
    
    print_menu_header "MAIN MENU"
    
    echo "1) Setup & Configuration             - Configure environment and deployment settings"
    echo "2) Project Deployment                - Deploy RHIS phases and components"
    echo "3) Testing & Validation              - Run syntax checks and validations"
    echo "4) Utilities & Maintenance           - Manage roles, templates, and project"
    echo "5) Network Boot Services             - Setup TFTP server for network installations"
    echo "6) Documentation                     - View project documentation"
    echo "7) Exit                              - Exit the menu system"
    echo ""
    read -p "Select menu (1-7): " main_choice
    
    case "$main_choice" in
        1) show_setup_menu ;;
        2) show_deployment_menu ;;
        3) show_testing_menu ;;
        4) show_utilities_menu ;;
        5) show_network_boot_menu ;;
        6) show_documentation_menu ;;
        7) 
            echo -e "${GREEN}Exiting RHIS Menu...${NC}"
            exit 0
            ;;
        *) 
            print_error "Invalid option. Please try again."
            pause_menu
            show_main_menu
            ;;
    esac
}

# ============================================================================
# CONFIGURE LOCAL ENVIRONMENT
# ============================================================================
configure_local_environment() {
    clear_screen
    print_header
    print_menu_header "CONFIGURE LOCAL ENVIRONMENT - COMPLETE SETUP"
    
    echo "This will configure your complete local environment for RHIS deployments."
    echo "This is a comprehensive setup including:"
    echo "  • Running initial setup and system prompts"
    echo "  • Configuring installer variables"
    echo "  • Selecting deployment scenario"
    echo "  • Selecting infrastructure platform"
    echo "  • Configuring integrations"
    echo "  • Installing dependencies and requirements"
    echo ""
    read -p "Continue with complete environment configuration? (y/n): " continue_setup
    
    if [[ "$continue_setup" != "y" && "$continue_setup" != "Y" ]]; then
        print_info "Configuration cancelled"
        pause_menu
        show_setup_menu
        return
    fi
    
    # Step 1: Run initial setup scripts
    print_info "Step 1/6: Running initial setup scripts..."
    echo ""
    if [ -f "${PROJECT_ROOT}/scripts/run_setup.sh" ]; then
        run_script run_setup --project-root "${PROJECT_ROOT}"
        print_success "Setup script completed"
    else
        print_error "scripts/run_setup.sh not found"
    fi
    echo ""
    
    if [ -f "${PROJECT_ROOT}/system_prompts.yml" ]; then
        print_info "Running system prompts configuration..."
        cd "${PROJECT_ROOT}" && ansible-playbook system_prompts.yml -i localhost,
        print_success "System prompts completed"
    else
        print_error "system_prompts.yml not found (non-critical, continuing...)"
    fi
    pause_menu
    
    # Step 2: Configure Red Hat Credentials (REQUIRED for downloading collections)
    clear_screen
    print_header
    print_menu_header "STEP 2/6: RED HAT CREDENTIALS & SECRETS"
    echo ""
    echo "To download Ansible collections from Red Hat, we need your credentials."
    echo "Visit https://console.redhat.com/api/automation-hub/token/ to get your token."
    echo ""
    
    read -p "Red Hat account username (SSO): " rh_username
    read -sp "Red Hat account password: " rh_password
    echo ""
    
    read -p "Automation Hub API token (from console.redhat.com): " rh_hub_token
    
    print_success "Red Hat credentials configured"
    pause_menu
    
    # Step 3: Configure installer variables
    clear_screen
    print_header
    print_menu_header "STEP 3/6: INSTALLER VARIABLES"
    echo ""
    
    read -p "Installer username (default: ${USER}): " installer_user
    installer_user=${installer_user:-${USER}}
    
    read -p "Installer home directory (default: /home/${installer_user}): " installer_home
    installer_home=${installer_home:-/home/${installer_user}}
    
    read -p "Installer email: " installer_email
    
    read -p "Ansible user (default: ansible): " ansible_user
    ansible_user=${ansible_user:-ansible}
    
    read -p "Project environment (dev/test/prod, default: dev): " project_env
    project_env=${project_env:-dev}
    
    print_success "Installer variables configured"
    pause_menu
    
    # Step 4: Configure scenario
    clear_screen
    print_header
    print_menu_header "STEP 4/6: DEPLOYMENT SCENARIO"
    echo ""
    
    scenarios=(
        "Satellite Only"
        "Ansible Automation Platform (AAP) Only"
        "Identity Management (IdM) Only"
        "Satellite + AAP"
        "Satellite + IdM"
        "AAP + IdM"
        "Satellite + AAP + IdM (Full Stack - Default)"
    )
    
    echo "Select deployment scenario:"
    echo ""
    for i in "${!scenarios[@]}"; do
        printf "%d) %s\n" $((i+1)) "${scenarios[$i]}"
    done
    echo ""
    read -p "Select scenario (1-${#scenarios[@]}): " scenario_choice
    
    if [ "$scenario_choice" -lt 1 ] || [ "$scenario_choice" -gt "${#scenarios[@]}" ]; then
        scenario_choice=7
        print_info "Using default: Full Stack"
    fi
    
    selected_scenario="${scenarios[$((scenario_choice-1))]}"
    print_success "Selected Scenario: $selected_scenario"
    pause_menu
    
    # Map scenario selection
    case "$scenario_choice" in
        1) scenario_name="satellite_only" ;;
        2) scenario_name="aap_only" ;;
        3) scenario_name="idm_only" ;;
        4) scenario_name="satellite_aap" ;;
        5) scenario_name="satellite_idm" ;;
        6) scenario_name="aap_idm" ;;
        7) scenario_name="full_stack" ;;
    esac
    
    # Step 5: Configure platform
    clear_screen
    print_header
    print_menu_header "STEP 5/6: INFRASTRUCTURE PLATFORM"
    echo ""
    
    platforms=(
        "Libvirt (Local KVM/QEMU)"
        "Nutanix AHV"
        "VMware vSphere"
        "Amazon Web Services (AWS)"
        "Google Cloud Platform (GCP)"
        "Microsoft Azure"
    )
    
    echo "Select deployment platform:"
    echo ""
    for i in "${!platforms[@]}"; do
        printf "%d) %s\n" $((i+1)) "${platforms[$i]}"
    done
    echo ""
    read -p "Select platform (1-${#platforms[@]}): " platform_choice
    
    if [ "$platform_choice" -lt 1 ] || [ "$platform_choice" -gt "${#platforms[@]}" ]; then
        platform_choice=1
        print_info "Using default: Libvirt"
    fi
    
    selected_platform="${platforms[$((platform_choice-1))]}"
    print_success "Selected Platform: $selected_platform"
    pause_menu
    
    # Map platform selection
    case "$platform_choice" in
        1) platform_name="libvirt" ;;
        2) platform_name="nutanix" ;;
        3) platform_name="vmware" ;;
        4) platform_name="aws" ;;
        5) platform_name="gcp" ;;
        6) platform_name="azure" ;;
    esac
    
    # Step 6: Configure integrations
    clear_screen
    print_header
    print_menu_header "STEP 6/6: INTEGRATIONS CONFIGURATION"
    echo ""
    
    echo "Select integrations to configure (comma-separated, or leave blank for none):"
    echo ""
    echo "Available integrations:"
    echo "  servicenow     - ServiceNow integration"
    echo "  jira           - Atlassian Jira integration"
    echo "  splunk         - Splunk logging/analytics"
    echo "  datadog        - Datadog monitoring"
    echo "  awx            - AWX integration"
    echo "  controller     - AAP Controller integration"
    echo "  hub            - Automation Hub integration"
    echo "  eda            - Event Driven Automation integration"
    echo "  insights       - Red Hat Insights integration"
    echo "  satellite      - Satellite integration"
    echo ""
    read -p "Select integrations (or press Enter for none): " integrations_input
    
    print_success "Integrations configured: ${integrations_input:-none}"
    pause_menu
    
    # Step 7: Install dependencies and requirements
    clear_screen
    print_header
    print_menu_header "STEP 7/7: INSTALLING DEPENDENCIES & REQUIREMENTS"
    echo ""
    
    print_info "Creating configuration directories..."
    mkdir -p "${PROJECT_ROOT}/.deployment_config"
    mkdir -p "${PROJECT_ROOT}/.ansible/conf"
    mkdir -p "${installer_home}/.ansible/conf"
    mkdir -p "${installer_home}/Downloads/RedHat_Management"
    
    print_info "Saving installer configuration..."
    cat > "${PROJECT_ROOT}/.deployment_config/installer.conf" << EOF
# Installer Configuration
INSTALLER_USER="${installer_user}"
INSTALLER_HOME="${installer_home}"
INSTALLER_EMAIL="${installer_email}"
ANSIBLE_USER="${ansible_user}"
PROJECT_ENV="${project_env}"
SCENARIO_NAME="${scenario_name}"
SCENARIO_LABEL="${selected_scenario}"
PLATFORM_NAME="${platform_name}"
PLATFORM_LABEL="${selected_platform}"
INTEGRATIONS="${integrations_input}"
GENERATION_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
PROJECT_ROOT="${PROJECT_ROOT}"
EOF
    print_success "Installer configuration saved"
    echo ""
    
    print_info "Creating vault for secrets..."
    VAULT_PASS_FILE="${installer_home}/.ansible/conf/.vault_pass.txt"
    mkdir -p "$(dirname "$VAULT_PASS_FILE")"
    
    # Generate vault password file
    read -sp "Enter vault password (for encrypting secrets): " vault_password
    echo ""
    echo "$vault_password" > "$VAULT_PASS_FILE"
    chmod 600 "$VAULT_PASS_FILE"
    print_success "Vault password file created"
    echo ""
    
    print_info "Creating encrypted environment configuration..."
    ENV_YML="${installer_home}/.ansible/conf/env.yml"
    
    # Create temporary unencrypted env.yml with Red Hat credentials
    cat > "${ENV_YML}.tmp" << 'ENVEOF'
---
# Red Hat Credentials
redhat:
  account_username: "REDHAT_USERNAME"
  account_password: "REDHAT_PASSWORD"
  automation_hub_token: "REDHAT_HUB_TOKEN"
  sso_username: null
  sso_password: null

# Global Admin Credentials
global_admin_user: "admin"
global_admin_password: "CHANGEME_GLOBAL_ADMIN_PASSWORD"

# Satellite Configuration
satellite_fqdn: "satellite.example.com"
satellite_admin_user: "admin"
satellite_admin_password: "CHANGEME_SATELLITE_PASSWORD"
satellite_api_user: "api_user"
satellite_api_password: "CHANGEME_SATELLITE_API_PASSWORD"

# AAP Configuration
aap_controller_fqdn: "controller.example.com"
aap_hub_fqdn: "hub.example.com"
aap_controller_admin_user: "admin"
aap_controller_admin_password: "CHANGEME_AAP_PASSWORD"

# IdM Configuration
idm_server_fqdn: "idm.example.com"
idm_admin_user: "admin"
idm_admin_password: "CHANGEME_IDM_PASSWORD"
idm_dm_password: "CHANGEME_IDM_DM_PASSWORD"
ENVEOF
    
    # Replace placeholders with actual credentials
    sed -i "s|REDHAT_USERNAME|${rh_username}|g" "${ENV_YML}.tmp"
    sed -i "s|REDHAT_PASSWORD|${rh_password}|g" "${ENV_YML}.tmp"
    sed -i "s|REDHAT_HUB_TOKEN|${rh_hub_token}|g" "${ENV_YML}.tmp"
    
    # Encrypt with ansible-vault
    ansible-vault encrypt --vault-password-file "$VAULT_PASS_FILE" "${ENV_YML}.tmp" 2>/dev/null
    mv "${ENV_YML}.tmp" "$ENV_YML"
    chmod 600 "$ENV_YML"
    
    print_success "Encrypted environment configuration created at $ENV_YML"
    echo ""
    
    print_info "Installing Python dependencies..."
    pip3 install --user -q pyyaml jinja2 requests 2>/dev/null || print_error "Some pip packages failed (non-critical)"
    print_success "Python dependencies installed"
    echo ""
    
    print_info "Installing Ansible collections with Red Hat credentials..."
    # Configure ansible-galaxy to use vault password
    export ANSIBLE_VAULT_PASSWORD_FILE="$VAULT_PASS_FILE"
    cd "${PROJECT_ROOT}" && ansible-galaxy collection install -r requirements.yml -p collections/ansible_collections --force
    print_success "Collections installed"
    echo ""
    
    print_info "Installing collection requirements from extended requirements..."
    if [ -f "${PROJECT_ROOT}/collections/requirements-extended.yml" ]; then
        cd "${PROJECT_ROOT}" && ansible-galaxy collection install -r collections/requirements-extended.yml -p collections/ansible_collections --force
        print_success "Extended collections installed"
    fi
    echo ""
    
    print_info "Installing role requirements..."
    if [ -f "${PROJECT_ROOT}/requirements.yml" ]; then
        cd "${PROJECT_ROOT}" && ansible-galaxy role install -r requirements.yml --force
        print_success "Role requirements installed"
    fi
    echo ""
    
    print_info "Configuring installer user and system..."
    mkdir -p "${installer_home}/.ssh"
    mkdir -p "${installer_home}/.ansible/conf"
    chmod 700 "${installer_home}/.ssh"
    
    # Create ansible.cfg for installer
    cat > "${installer_home}/.ansible/conf/ansible.cfg" << 'EOF'
[defaults]
inventory = ./inventory/hosts
roles_path = ./roles
collections_paths = ./collections/ansible_collections
ansible_managed = Ansible: {file} {date} {time} by {uid} on {host}
host_key_checking = False
forks = 5
timeout = 30

[privilege_escalation]
become = True
become_method = sudo
become_user = root
EOF
    print_success "Ansible configuration created for installer"
    echo ""
    
    # Generate environment configuration
    print_info "Generating environment configuration file..."
    cat > "${installer_home}/.ansible/conf/env.conf" << EOF
# Environment Configuration for ${installer_user}
export ANSIBLE_USER="${ansible_user}"
export INSTALLER_USER="${installer_user}"
export PROJECT_ENV="${project_env}"
export SCENARIO="${scenario_name}"
export PLATFORM="${platform_name}"
export PROJECT_ROOT="${PROJECT_ROOT}"
export ANSIBLE_CONFIG="${installer_home}/.ansible/conf/ansible.cfg"
export ANSIBLE_INVENTORY="${PROJECT_ROOT}/inventory/hosts"
EOF
    print_success "Environment configuration saved"
    echo ""
    
    # Summary
    clear_screen
    print_header
    print_menu_header "ENVIRONMENT CONFIGURATION COMPLETE [SUCCESS]"
    
    cat << EOF


                    CONFIGURATION SUMMARY                              
╝

INSTALLER:
  Username:              ${installer_user}
  Home:                  ${installer_home}
  Email:                 ${installer_email}
  Ansible User:          ${ansible_user}
  Environment:           ${project_env}

DEPLOYMENT:
  Scenario:              ${selected_scenario}
  Platform:              ${selected_platform}
  Integrations:          ${integrations_input:-none}

LOCATIONS:
  Configuration:         ${PROJECT_ROOT}/.deployment_config/installer.conf
  Ansible Config:        ${installer_home}/.ansible/conf/ansible.cfg
  Environment Vars:      ${installer_home}/.ansible/conf/env.conf
  Project Root:          ${PROJECT_ROOT}

INSTALLED COMPONENTS:
  [SUCCESS] Python dependencies
  [SUCCESS] Ansible collections
  [SUCCESS] Project bootstrap
  [SUCCESS] Role requirements
  [SUCCESS] Installer user setup

NEXT STEPS:
1. Source environment configuration:
   source ${installer_home}/.ansible/conf/env.conf

2. Configure vault for sensitive data:
   ansible-vault create ${installer_home}/.ansible/conf/vault.yml

3. Test Ansible connectivity:
   ansible all -i inventory/hosts -m ping

4. Deploy using RHIS-Menu or playbooks:
   ${SCRIPT_DIR}/RHIS-Menu.sh

╝

EOF
    
    print_success "All environment configuration completed!"
    pause_menu
    show_setup_menu
}

# ============================================================================
# SETUP & CONFIGURATION MENU
# ============================================================================
show_setup_menu() {
    clear_screen
    print_header
    
    print_menu_header "SETUP & CONFIGURATION"
    
    echo "1) Configure Local Environment       - Complete setup with Red Hat credentials"
    echo "2) Install Ansible Collections       - Download and install required collections"
    echo "3) Install Collections with Updates  - Install collections and update roles"
    echo "4) Configure Infrastructure          - Setup infrastructure and generate inventory"
    echo ""
    echo "Recommended: Start with option 1 for complete initial setup"
    echo "            Then option 4 to configure your infrastructure"
    echo ""
    echo "0) Back to Main Menu"
    echo ""
    read -p "Select option (0-4): " setup_choice
    
    case "$setup_choice" in
        1) 
            configure_local_environment
            ;;
        2) 
            print_info "Installing Ansible Collections..."
            cd "${PROJECT_ROOT}" && ansible-galaxy collection install -r requirements.yml -p collections/ansible_collections --force
            print_success "Collections installed"
            pause_menu
            show_setup_menu
            ;;
        3) 
            print_info "Installing Collections with Extended Requirements..."
            cd "${PROJECT_ROOT}" && ansible-galaxy collection install -r requirements.yml -p collections/ansible_collections --force
            if [ -f "${PROJECT_ROOT}/collections/requirements-extended.yml" ]; then
                ansible-galaxy collection install -r collections/requirements-extended.yml -p collections/ansible_collections --force
            fi
            print_success "Collections and extended requirements installed"
            pause_menu
            show_setup_menu
            ;;
        4)
            print_info "Configuring Infrastructure..."
            run_playbook "playbooks/infrastructure-setup.yml"
            print_success "Infrastructure configuration complete"
            pause_menu
            show_setup_menu
            ;;
        0) 
            show_main_menu
            ;;
        *) 
            print_error "Invalid option"
            pause_menu
            show_setup_menu
            ;;
    esac
}

# ============================================================================
# SCENARIO & PLATFORM SELECTION MENU
# ============================================================================
show_scenario_platform_menu() {
    clear_screen
    print_header
    
    print_menu_header "SCENARIO & PLATFORM SELECTION - GENERATE VARIABLES"
    
    # Array of available scenarios
    scenarios=(
        "Satellite Only"
        "Ansible Automation Platform (AAP) Only"
        "Identity Management (IdM) Only"
        "Satellite + AAP"
        "Satellite + IdM"
        "AAP + IdM"
        "Satellite + AAP + IdM (Full Stack - Default)"
    )
    
    echo "Select deployment scenario:"
    echo ""
    for i in "${!scenarios[@]}"; do
        printf "%d) %s\n" $((i+1)) "${scenarios[$i]}"
    done
    echo ""
    read -p "Select scenario (1-${#scenarios[@]}): " scenario_choice
    
    if [ "$scenario_choice" -lt 1 ] || [ "$scenario_choice" -gt "${#scenarios[@]}" ]; then
        print_error "Invalid scenario selection"
        pause_menu
        show_scenario_platform_menu
        return
    fi
    
    selected_scenario="${scenarios[$((scenario_choice-1))]}"
    print_info "Selected Scenario: $selected_scenario"
    echo ""
    
    # Array of available platforms
    platforms=(
        "Libvirt (Local KVM/QEMU)"
        "Nutanix AHV"
        "VMware vSphere"
        "Amazon Web Services (AWS)"
        "Google Cloud Platform (GCP)"
        "Microsoft Azure"
    )
    
    echo "Select deployment platform:"
    echo ""
    for i in "${!platforms[@]}"; do
        printf "%d) %s\n" $((i+1)) "${platforms[$i]}"
    done
    echo ""
    read -p "Select platform (1-${#platforms[@]}): " platform_choice
    
    if [ "$platform_choice" -lt 1 ] || [ "$platform_choice" -gt "${#platforms[@]}" ]; then
        print_error "Invalid platform selection"
        pause_menu
        show_scenario_platform_menu
        return
    fi
    
    selected_platform="${platforms[$((platform_choice-1))]}"
    print_info "Selected Platform: $selected_platform"
    echo ""
    
    # Map selections to internal names
    case "$scenario_choice" in
        1) scenario_name="satellite_only" ;;
        2) scenario_name="aap_only" ;;
        3) scenario_name="idm_only" ;;
        4) scenario_name="satellite_aap" ;;
        5) scenario_name="satellite_idm" ;;
        6) scenario_name="aap_idm" ;;
        7) scenario_name="full_stack" ;;
    esac
    
    case "$platform_choice" in
        1) platform_name="libvirt" ;;
        2) platform_name="nutanix" ;;
        3) platform_name="vmware" ;;
        4) platform_name="aws" ;;
        5) platform_name="gcp" ;;
        6) platform_name="azure" ;;
    esac
    
    # Generate variables
    print_info "Generating variables for ${scenario_name} on ${platform_name}..."
    echo ""
    generate_deployment_variables "$scenario_name" "$platform_name" "$selected_scenario" "$selected_platform"
    
    pause_menu
    show_setup_menu
}

# ============================================================================
# GENERATE DEPLOYMENT VARIABLES
# ============================================================================
generate_deployment_variables() {
    local scenario="$1"
    local platform="$2"
    local scenario_label="$3"
    local platform_label="$4"
    
    print_info "Generating deployment configuration..."
    echo ""
    
    # Create deployment configuration directory if it doesn't exist
    local config_dir="${PROJECT_ROOT}/.deployment_config"
    mkdir -p "${config_dir}"
    
    # Create scenario and platform configuration files
    cat > "${config_dir}/scenario.conf" << EOF
SCENARIO_NAME="${scenario}"
SCENARIO_LABEL="${scenario_label}"
PLATFORM_NAME="${platform}"
PLATFORM_LABEL="${platform_label}"
GENERATION_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
PROJECT_ROOT="${PROJECT_ROOT}"
EOF
    
    print_success "Scenario configuration saved to ${config_dir}/scenario.conf"
    echo ""
    
    # Generate based on scenario
    case "$scenario" in
        satellite_only)
            generate_satellite_vars "${platform}"
            ;;
        aap_only)
            generate_aap_vars "${platform}"
            ;;
        idm_only)
            generate_idm_vars "${platform}"
            ;;
        satellite_aap)
            generate_satellite_vars "${platform}"
            generate_aap_vars "${platform}"
            ;;
        satellite_idm)
            generate_satellite_vars "${platform}"
            generate_idm_vars "${platform}"
            ;;
        aap_idm)
            generate_aap_vars "${platform}"
            generate_idm_vars "${platform}"
            ;;
        full_stack)
            generate_satellite_vars "${platform}"
            generate_aap_vars "${platform}"
            generate_idm_vars "${platform}"
            ;;
    esac
    
    # Generate vault setup
    generate_vault_setup "${scenario}" "${platform}"
    
    # Generate environment configuration
    generate_env_config "${scenario}" "${platform}"
    
    # Generate host vars for each product
    generate_host_vars "${scenario}" "${platform}"
    
    # Generate inventory template
    generate_inventory "${scenario}" "${platform}"
    
    print_success "All deployment variables generated successfully!"
    echo ""
    echo "Configuration files created in:"
    echo "  • ${config_dir}/"
    echo "  • ${PROJECT_ROOT}/host_vars/"
    echo "  • ${PROJECT_ROOT}/.ansible/conf/ (env variables)"
    echo "  • Vault configuration ready"
}

generate_satellite_vars() {
    local platform="$1"
    print_info "Generating Satellite variables..."
    mkdir -p "${PROJECT_ROOT}/host_vars"
    touch "${PROJECT_ROOT}/host_vars/satellite.yml"
    print_success "Satellite variables template created"
}

generate_aap_vars() {
    local platform="$1"
    print_info "Generating AAP variables..."
    mkdir -p "${PROJECT_ROOT}/host_vars"
    touch "${PROJECT_ROOT}/host_vars/aap.yml"
    print_success "AAP variables template created"
}

generate_idm_vars() {
    local platform="$1"
    print_info "Generating IdM variables..."
    mkdir -p "${PROJECT_ROOT}/host_vars"
    touch "${PROJECT_ROOT}/host_vars/idm.yml"
    print_success "IdM variables template created"
}

generate_vault_setup() {
    local scenario="$1"
    local platform="$2"
    print_info "Setting up Ansible Vault..."
    mkdir -p "${PROJECT_ROOT}/.ansible/conf"
    
    # Create vault password file template
    cat > "${PROJECT_ROOT}/.ansible/conf/vault_password_prompt.sh" << 'EOF'
#!/bin/bash
# Vault password prompt script
read -sp "Vault password: " vault_pass
echo "$vault_pass"
EOF
    chmod +x "${PROJECT_ROOT}/.ansible/conf/vault_password_prompt.sh"
    print_success "Vault configuration initialized"
}

generate_env_config() {
    local scenario="$1"
    local platform="$2"
    print_info "Generating environment configuration..."
    mkdir -p "${PROJECT_ROOT}/.ansible/conf"
    
    # Create env.yml template with structure
    # Create an example env template under docs/examples to avoid writing
    # a user-local config into the project root
    mkdir -p "${PROJECT_ROOT}/docs/examples"
    cat > "${PROJECT_ROOT}/docs/examples/env.yml.template" << 'EOF'
---
# Ansible Environment Configuration Template
# Copy to ~/.ansible/conf/env.yml and populate with your values

# Global Admin Credentials
global_admin_user: "admin"
global_admin_password: "{{ vault_global_admin_password }}"

# Satellite Configuration
satellite_fqdn: "satellite.example.com"
satellite_admin_user: "admin"
satellite_admin_password: "{{ vault_satellite_password }}"
satellite_api_user: "api_user"
satellite_api_password: "{{ vault_satellite_api_password }}"

# AAP Configuration
aap_controller_fqdn: "controller.example.com"
aap_hub_fqdn: "hub.example.com"
aap_controller_admin_user: "admin"
aap_controller_admin_password: "{{ vault_aap_password }}"

# IdM Configuration
idm_server_fqdn: "idm.example.com"
idm_admin_user: "admin"
idm_admin_password: "{{ vault_idm_password }}"
idm_dm_password: "{{ vault_idm_dm_password }}"

# Cloud Platform Credentials (if applicable)
# AWS
aws_access_key_id: "{{ vault_aws_access_key }}"
aws_secret_access_key: "{{ vault_aws_secret_key }}"

# GCP
gcp_project_id: "{{ vault_gcp_project }}"
gcp_service_account_email: "{{ vault_gcp_email }}"

# Azure
azure_subscription_id: "{{ vault_azure_subscription }}"
azure_client_id: "{{ vault_azure_client_id }}"
azure_client_secret: "{{ vault_azure_secret }}"
EOF
    
    print_success "Environment template created at ${PROJECT_ROOT}/docs/examples/env.yml.template"
}

generate_host_vars() {
    local scenario="$1"
    local platform="$2"
    print_info "Generating host variables..."
    mkdir -p "${PROJECT_ROOT}/host_vars"
    
    # Create platform-specific variables
    cat > "${PROJECT_ROOT}/host_vars/platform_${platform}.yml" << EOF
---
# Platform: ${platform}
# Generated deployment variables

deployment_platform: "${platform}"
EOF
    
    print_success "Platform variables created: host_vars/platform_${platform}.yml"
}

generate_inventory() {
    local scenario="$1"
    local platform="$2"
    print_info "Generating inventory structure..."
    
    # Create inventory groups file
    cat > "${PROJECT_ROOT}/inventory/deployment.yml" << EOF
---
all:
  vars:
    scenario: "${scenario}"
    platform: "${platform}"
  
  children:
    products:
      children:
        satellite:
          hosts: {}
        aap:
          hosts: {}
        idm:
          hosts: {}
    
    infrastructure:
      children:
        libvirt:
          hosts: {}
        nutanix:
          hosts: {}
        vmware:
          hosts: {}
        cloud:
          hosts: {}
EOF
    
    print_success "Inventory template created: inventory/deployment.yml"
}

# ============================================================================
# PROJECT DEPLOYMENT MENU
# ============================================================================
show_deployment_menu() {
    clear_screen
    print_header
    
    print_menu_header "PROJECT DEPLOYMENT"
    
    echo "RHIS Deployment Phases (Execute in Order):"
    echo ""
    echo "1) Deploy Complete RHIS Environment  - Deploy all RHIS phases (6 phases)"
    echo "2) Phase 1: Infrastructure Init      - Initialize and prepare infrastructure"
    echo "3) Phase 2: Deploy IDM              - Deploy Identity Management services"
    echo "4) Phase 3: Deploy Satellite        - Deploy Red Hat Satellite"
    echo "5) Phase 4: Provision Hosts         - Provision infrastructure hosts"
    echo "6) Phase 5: AAP Controller Setup     - Configure AAP Controller"
    echo "7) Phase 6: AAP Deployment          - Complete AAP deployment"
    echo ""
    echo "Advanced Deployment:"
    echo "8) Deploy Components Only            - Deploy selected components"
    echo "9) Deploy RedHat Management Site     - Run RedHat Management playbook"
    echo "10) Custom Playbook Execution        - Execute custom ansible playbook"
    echo ""
    echo "0) Back to Main Menu"
    echo ""
    read -p "Select option (0-10): " deploy_choice
    
    case "$deploy_choice" in
        1) 
            print_info "Deploying complete RHIS environment..."
            run_playbook "playbooks/rhis_build_complete.yml"
            print_success "RHIS deployment complete"
            pause_menu
            show_deployment_menu
            ;;
        2) 
            print_info "Deploying Phase 1: Infrastructure Initialization..."
            run_playbook "playbooks/rhis_build_complete.yml" -t rhis_phase_1
            print_success "Phase 1 complete"
            pause_menu
            show_deployment_menu
            ;;
        3) 
            print_info "Deploying Phase 2: IDM..."
            run_playbook "playbooks/rhis_build_complete.yml" -t rhis_phase_2
            print_success "Phase 2 complete"
            pause_menu
            show_deployment_menu
            ;;
        4) 
            print_info "Deploying Phase 3: Satellite..."
            run_playbook "playbooks/rhis_build_complete.yml" -t rhis_phase_3
            print_success "Phase 3 complete"
            pause_menu
            show_deployment_menu
            ;;
        5) 
            print_info "Deploying Phase 4: Host Provisioning..."
            run_playbook "playbooks/rhis_build_complete.yml" -t rhis_phase_4
            print_success "Phase 4 complete"
            pause_menu
            show_deployment_menu
            ;;
        6) 
            print_info "Deploying Phase 5: AAP Controller Setup..."
            run_playbook "playbooks/rhis_build_complete.yml" -t rhis_phase_5
            print_success "Phase 5 complete"
            pause_menu
            show_deployment_menu
            ;;
        7) 
            print_info "Deploying Phase 6: AAP Deployment..."
            run_playbook "playbooks/rhis_build_complete.yml" -t rhis_phase_6
            print_success "Phase 6 complete"
            pause_menu
            show_deployment_menu
            ;;
        8) 
            print_info "Deploying components only..."
            run_playbook "playbooks/deploy_components-site.yml"
            print_success "Components deployed"
            pause_menu
            show_deployment_menu
            ;;
        9) 
            print_info "Deploying RedHat Management site..."
            run_playbook "redhat_management-site.yml"
            print_success "RedHat Management site deployed"
            pause_menu
            show_deployment_menu
            ;;
        10) 
            read -p "Enter playbook path (relative to project root): " playbook_path
            if [ -f "${PROJECT_ROOT}/${playbook_path}" ]; then
                print_info "Executing: ${playbook_path}"
                run_playbook "${playbook_path}"
                print_success "Playbook execution complete"
            else
                print_error "Playbook not found: ${playbook_path}"
            fi
            pause_menu
            show_deployment_menu
            ;;
        0) 
            show_main_menu
            ;;
        *) 
            print_error "Invalid option"
            pause_menu
            show_deployment_menu
            ;;
    esac
}

# ============================================================================
# VALIDATION FUNCTIONS FOR TESTING
# ============================================================================

validate_dhcp_configuration() {
    local temp_output=$(mktemp)
    local pass_count=0
    local fail_count=0
    
    echo ""
    print_menu_header "DHCP CONFIGURATION VALIDATION"
    
    # Test 1: Check if group_vars/all.yml has correct DHCP range start
    if grep -q "satellite_dhcp_range_start: '10.168.0.100'" "${PROJECT_ROOT}/group_vars/all.yml"; then
        echo "✓ PASS: DHCP range start is 10.168.0.100"
        ((pass_count++))
    else
        echo "✗ FAIL: DHCP range start not correctly set"
        ((fail_count++))
    fi
    
    # Test 2: Check if group_vars/all.yml has correct DHCP range end
    if grep -q "satellite_dhcp_range_end: '10.168.0.254'" "${PROJECT_ROOT}/group_vars/all.yml"; then
        echo "✓ PASS: DHCP range end is 10.168.0.254"
        ((pass_count++))
    else
        echo "✗ FAIL: DHCP range end not correctly set"
        ((fail_count++))
    fi
    
    # Test 3: Check if template has correct defaults
    if grep -q "default('10.168.0.100')" "${PROJECT_ROOT}/templates/misc/env.yml.j2"; then
        echo "✓ PASS: Template DHCP start default is 10.168.0.100"
        ((pass_count++))
    else
        echo "✗ FAIL: Template DHCP start default incorrect"
        ((fail_count++))
    fi
    
    if grep -q "default('10.168.0.254')" "${PROJECT_ROOT}/templates/misc/env.yml.j2"; then
        echo "✓ PASS: Template DHCP end default is 10.168.0.254"
        ((pass_count++))
    else
        echo "✗ FAIL: Template DHCP end default incorrect"
        ((fail_count++))
    fi
    
    # Test 4: Check network gateway configuration
    if grep -q "satellite_gateway: 10.168.0.1" "${PROJECT_ROOT}/group_vars/all.yml"; then
        echo "✓ PASS: Satellite gateway is 10.168.0.1"
        ((pass_count++))
    else
        echo "✗ FAIL: Satellite gateway not correctly set"
        ((fail_count++))
    fi
    
    # Test 5: Check network subnet configuration
    if grep -q "satellite_dhcp_network: 10.168.0.0" "${PROJECT_ROOT}/group_vars/all.yml"; then
        echo "✓ PASS: DHCP network is 10.168.0.0"
        ((pass_count++))
    else
        echo "✗ FAIL: DHCP network not correctly set"
        ((fail_count++))
    fi
    
    # Test 6: Check Foreman proxy DHCP variables reference satellites variables
    if grep -q 'start: "{{ satellite_dhcp_range_start }}"' "${PROJECT_ROOT}/group_vars/all.yml"; then
        echo "✓ PASS: Foreman DHCP range start references satellite_dhcp_range_start"
        ((pass_count++))
    else
        echo "✗ FAIL: Foreman DHCP range start configuration issue"
        ((fail_count++))
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "DHCP Configuration Validation Results:"
    echo "  Passed: $pass_count"
    echo "  Failed: $fail_count"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ $fail_count -eq 0 ]; then
        print_success "All DHCP configuration tests passed!"
        return 0
    else
        print_error "Some DHCP configuration tests failed. See above for details."
        return 1
    fi
    
    rm -f "$temp_output"
}

test_default_scenario() {
    local temp_output=$(mktemp)
    local pass_count=0
    local fail_count=0
    
    echo ""
    print_menu_header "DEFAULT SCENARIO TEST (Satellite + AAP + IdM)"
    
    # Test 1: Verify infrastructure setup playbook exists and has valid syntax
    if [ -f "${PROJECT_ROOT}/playbooks/infrastructure-setup.yml" ]; then
        echo "✓ PASS: infrastructure-setup.yml exists"
        ((pass_count++))
        
        if cd "${PROJECT_ROOT}" && ansible-playbook --syntax-check playbooks/infrastructure-setup.yml &>/dev/null; then
            echo "✓ PASS: infrastructure-setup.yml syntax is valid"
            ((pass_count++))
        else
            echo "✗ FAIL: infrastructure-setup.yml has syntax errors"
            ((fail_count++))
        fi
    else
        echo "✗ FAIL: infrastructure-setup.yml does not exist"
        ((fail_count++))
    fi
    
    # Test 2: Verify deploy_components playbook exists
    if [ -f "${PROJECT_ROOT}/playbooks/deploy_components-site.yml" ]; then
        echo "✓ PASS: deploy_components-site.yml exists"
        ((pass_count++))
        
        if cd "${PROJECT_ROOT}" && ansible-playbook --syntax-check playbooks/deploy_components-site.yml &>/dev/null; then
            echo "✓ PASS: deploy_components-site.yml syntax is valid"
            ((pass_count++))
        else
            echo "✗ FAIL: deploy_components-site.yml has syntax errors"
            ((fail_count++))
        fi
    else
        echo "✗ FAIL: deploy_components-site.yml does not exist"
        ((fail_count++))
    fi
    
    # Test 3: Verify required roles exist
    local required_roles=("infrastructure_prep" "libvirt_vm_provisioner" "satellite_6_18_deployment" "aap" "idm_3_0_setup")
    for role in "${required_roles[@]}"; do
        if [ -d "${PROJECT_ROOT}/roles/${role}" ]; then
            echo "✓ PASS: Role '$role' exists"
            ((pass_count++))
        else
            echo "✗ FAIL: Required role '$role' not found"
            ((fail_count++))
        fi
    done
    
    # Test 4: Verify satellite variables configured correctly
    if [ -f "${PROJECT_ROOT}/group_vars/all.yml" ]; then
        echo "✓ PASS: group_vars/all.yml exists"
        ((pass_count++))
        
        if grep -q "satellite_ip: 10.168.0.27" "${PROJECT_ROOT}/group_vars/all.yml"; then
            echo "✓ PASS: Satellite IP is correctly configured (10.168.0.27)"
            ((pass_count++))
        else
            echo "✗ FAIL: Satellite IP not correctly configured"
            ((fail_count++))
        fi
    else
        echo "✗ FAIL: group_vars/all.yml does not exist"
        ((fail_count++))
    fi
    
    # Test 5: Verify AAP variables configured correctly
    if grep -q "aap_host_ip: 10.168.0.26" "${PROJECT_ROOT}/group_vars/all.yml"; then
        echo "✓ PASS: AAP IP is correctly configured (10.168.0.26)"
        ((pass_count++))
    else
        echo "✗ FAIL: AAP IP not correctly configured"
        ((fail_count++))
    fi
    
    # Test 6: Verify IdM variables configured correctly
    if grep -q "idm_ip: 10.168.0.28" "${PROJECT_ROOT}/group_vars/all.yml"; then
        echo "✓ PASS: IdM IP is correctly configured (10.168.0.28)"
        ((pass_count++))
    else
        echo "✗ FAIL: IdM IP not correctly configured"
        ((fail_count++))
    fi
    
    # Test 7: Verify inventory file exists
    if [ -f "${PROJECT_ROOT}/inventory/hosts" ]; then
        echo "✓ PASS: inventory/hosts exists"
        ((pass_count++))
    else
        echo "✗ FAIL: inventory/hosts does not exist"
        ((fail_count++))
    fi
    
    # Test 8: Verify requirements files exist
    if [ -f "${PROJECT_ROOT}/requirements.yml" ]; then
        echo "✓ PASS: requirements.yml exists"
        ((pass_count++))
    else
        echo "✗ FAIL: requirements.yml does not exist"
        ((fail_count++))
    fi
    
    # Test 9: Verify collections are listed
    if grep -q "containers.podman" "${PROJECT_ROOT}/requirements.yml"; then
        echo "✓ PASS: containers.podman collection is configured"
        ((pass_count++))
    else
        echo "✗ FAIL: containers.podman collection not found"
        ((fail_count++))
    fi
    
    if grep -q "community.libvirt" "${PROJECT_ROOT}/requirements.yml"; then
        echo "✓ PASS: community.libvirt collection is configured"
        ((pass_count++))
    else
        echo "✗ FAIL: community.libvirt collection not found"
        ((fail_count++))
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Default Scenario Test Results:"
    echo "  Passed: $pass_count"
    echo "  Failed: $fail_count"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ $fail_count -eq 0 ]; then
        print_success "All default scenario tests passed!"
        echo ""
        echo "Ready to deploy the default scenario (Satellite + AAP + IdM)!"
        echo ""
        echo "To deploy, select from the main menu:"
        echo "  - Project Deployment > Deploy Complete RHIS Environment"
        return 0
    else
        print_error "Some default scenario tests failed. See above for details."
        return 1
    fi
    
    rm -f "$temp_output"
}

# ============================================================================
# TESTING & VALIDATION MENU
# ============================================================================
show_testing_menu() {
    clear_screen
    print_header
    
    print_menu_header "TESTING & VALIDATION"
    
    echo "Recommended Test Order:"
    echo ""
    echo "1) Ansible Syntax Check              - Validate all playbook syntax"
    echo "2) Ansible Lint Check                - Run ansible-lint validation"
    echo "3) Syntax Check Updates              - Check syntax of role updates"
    echo "4) Validate Project Reorganization   - Verify project structure integrity"
    echo "5) Test Environment                  - Run environment configuration tests"
    echo "6) Validate DHCP Configuration       - Verify Satellite DHCP settings"
    echo "7) Test Default Scenario             - Test default (Satellite+AAP+IdM) deployment"
    echo "8) Run All Tests                     - Execute complete test suite"
    echo ""
    echo "0) Back to Main Menu"
    echo ""
    read -p "Select option (0-8): " test_choice
    
    case "$test_choice" in
        1) 
            print_info "Running Ansible syntax check..."
            cd "${PROJECT_ROOT}" && make test
            print_success "Syntax check complete"
            pause_menu
            show_testing_menu
            ;;
        2) 
            print_info "Running Ansible lint..."
            cd "${PROJECT_ROOT}" && make lint
            print_success "Lint check complete"
            pause_menu
            show_testing_menu
            ;;
        3) 
            print_info "Running syntax check on updates..."
            cd "${PROJECT_ROOT}" && make updates-test
            print_success "Updates syntax check complete"
            pause_menu
            show_testing_menu
            ;;
        4) 
            print_info "Validating project reorganization..."
            run_script validate-reorganization --project-root "${PROJECT_ROOT}"
            print_success "Validation complete"
            pause_menu
            show_testing_menu
            ;;
        5) 
            print_info "Testing environment configuration..."
            run_playbook "test-env.yml"
            print_success "Environment test complete"
            pause_menu
            show_testing_menu
            ;;
        6)
            print_info "Validating DHCP Configuration..."
            validate_dhcp_configuration
            pause_menu
            show_testing_menu
            ;;
        7)
            print_info "Testing default scenario (Satellite + AAP + IdM)..."
            test_default_scenario
            pause_menu
            show_testing_menu
            ;;
        8) 
            print_info "Running all tests..."
            cd "${PROJECT_ROOT}" && make test && make lint && make updates-test
            validate_dhcp_configuration
            test_default_scenario
            print_success "All tests complete"
            pause_menu
            show_testing_menu
            ;;
        0) 
            show_main_menu
            ;;
        *) 
            print_error "Invalid option"
            pause_menu
            show_testing_menu
            ;;
    esac
}

# ============================================================================
# UTILITIES & MAINTENANCE MENU
# ============================================================================
show_utilities_menu() {
    clear_screen
    print_header
    
    print_menu_header "UTILITIES & MAINTENANCE"
    
    echo "1) Generate Ansible Configuration    - Create ansible.cfg from settings"
    echo "2) Update Project Organization       - Run project update script"
    echo "3) List Available Roles              - Display all project roles"
    echo "4) List Available Templates          - Display template categories"
    echo "5) List Available Playbooks          - Display available playbooks"
    echo "6) Project Statistics                - Show project metrics"
    echo "7) Display Project Structure         - Show directory tree"
    echo "8) Clean Up Temporary Files          - Remove .tmp and .backup files"
    echo "9) Manage Red Hat Credentials        - Update/refresh Red Hat CDN tokens"
    echo ""
    echo "0) Back to Main Menu"
    echo ""
    read -p "Select option (0-9): " util_choice
    
    case "$util_choice" in
        1) 
            print_info "Generating Ansible configuration..."
            python3 "${PROJECT_ROOT}/generate_ansible_cfg.py"
            print_success "Configuration generated"
            pause_menu
            show_utilities_menu
            ;;
        2) 
            print_info "Running update script..."
            bash "${SCRIPT_DIR}/update.sh"
            print_success "Organization updated"
            pause_menu
            show_utilities_menu
            ;;
        3) 
            print_info "Available Roles:"
            echo ""
            find "${PROJECT_ROOT}/roles" -maxdepth 2 -type d -name "roles" -prune -o -maxdepth 2 -type d -print | grep -E "roles/[^/]+$" | sed 's|.*/||' | sort
            pause_menu
            show_utilities_menu
            ;;
        4) 
            print_info "Template Categories:"
            echo ""
            for dir in $(ls -1d "${PROJECT_ROOT}/templates"/*/ 2>/dev/null | sed 's|.*templates/||;s|/||' | sort); do
                count=$(ls -1 "${PROJECT_ROOT}/templates/${dir}" 2>/dev/null | wc -l)
                printf "%-20s (%3d files)\n" "${dir}:" "$count"
            done
            pause_menu
            show_utilities_menu
            ;;
        5) 
            print_info "Available Playbooks:"
            echo ""
            ls -1 "${PROJECT_ROOT}/playbooks"/*.yml 2>/dev/null | xargs basename -a | sort
            echo ""
            ls -1 "${PROJECT_ROOT}"/*.yml 2>/dev/null | xargs basename -a | sort
            pause_menu
            show_utilities_menu
            ;;
        6) 
            print_info "Project Statistics:"
            echo ""
            echo "Roles:"
            find "${PROJECT_ROOT}/roles" -type d -name "tasks" | wc -l
            echo ""
            echo "Templates:"
            find "${PROJECT_ROOT}/templates" -type f -name "*.j2" | wc -l
            echo ""
            echo "Playbooks:"
            find "${PROJECT_ROOT}" -maxdepth 1 -type f -name "*.yml" | wc -l
            plus_pb=$(find "${PROJECT_ROOT}/playbooks" -type f -name "*.yml" | wc -l)
            echo "  Main: $plus_pb"
            echo ""
            echo "Scripts:"
            ls -1 "${SCRIPT_DIR}"/*.sh 2>/dev/null | wc -l
            pause_menu
            show_utilities_menu
            ;;
        7) 
            print_info "Project Directory Structure:"
            echo ""
            tree -L 2 -d "${PROJECT_ROOT}" 2>/dev/null | head -50 || find "${PROJECT_ROOT}" -maxdepth 2 -type d | head -50
            pause_menu
            show_utilities_menu
            ;;
        8) 
            print_info "Cleaning temporary files..."
            find "${PROJECT_ROOT}" -name "*.tmp" -delete
            find "${PROJECT_ROOT}" -name "*.backup" -delete
            find "${PROJECT_ROOT}" -type f -name ".DS_Store" -delete
            print_success "Cleanup complete"
            pause_menu
            show_utilities_menu
            ;;
        9)
            clear_screen
            print_header
            print_menu_header "RED HAT CREDENTIALS MANAGEMENT"
            echo ""
            
            ENV_YML="${HOME}/.ansible/conf/env.yml"
            VAULT_PASS_FILE="${HOME}/.ansible/conf/.vault_pass.txt"
            
            if [ ! -f "$ENV_YML" ] || [ ! -f "$VAULT_PASS_FILE" ]; then
                print_error "Red Hat credentials not yet configured."
                print_info "Please run: Configure Local Environment from the main menu"
                pause_menu
                show_utilities_menu
                return
            fi
            
            echo "Choose an action:"
            echo "1) View Red Hat credentials (decrypt and display)"
            echo "2) Update Red Hat credentials"
            echo "3) Load credentials into current shell"
            echo "4) Test Red Hat Automation Hub connectivity"
            echo "0) Back"
            echo ""
            read -p "Select option (0-4): " rh_choice
            
            case "$rh_choice" in
                1)
                    print_info "Decrypting credentials..."
                    ansible-vault view "$ENV_YML" --vault-password-file "$VAULT_PASS_FILE" | grep -A 5 "^redhat:"
                    pause_menu
                    ;;
                2)
                    print_info "Opening credentials for editing..."
                    ansible-vault edit "$ENV_YML" --vault-password-file "$VAULT_PASS_FILE"
                    print_success "Credentials updated"
                    pause_menu
                    ;;
                3)
                    print_info "Loading Red Hat credentials..."
                    if bash "${SCRIPT_DIR}/load_redhat_credentials.sh"; then
                        print_success "Credentials loaded. Environment variables are set."
                        echo ""
                        echo "To use in your current shell:"
                        echo "  source ${SCRIPT_DIR}/load_redhat_credentials.sh"
                        pause_menu
                    else
                        print_error "Failed to load credentials"
                        pause_menu
                    fi
                    ;;
                4)
                    print_info "Testing Automation Hub connectivity..."
                    if bash "${PROJECT_ROOT}/scripts/load_redhat_credentials.sh" 2>/dev/null; then
                        if ansible-galaxy collection download "redhat.rhel_system_roles" --version 1.0.0 -p /tmp/rh_test 2>&1 | grep -q "successfully"; then
                            print_success "[SUCCESS] Red Hat Automation Hub is accessible"
                        else
                            print_error "[FAILED] Could not download test collection (may need valid credentials)"
                        fi
                    else
                        print_error "Could not load credentials for testing"
                    fi
                    pause_menu
                    ;;
                0)
                    ;;
                *)
                    print_error "Invalid option"
                    pause_menu
                    ;;
            esac
            show_utilities_menu
            ;;
        0) 
            show_main_menu
            ;;
        *) 
            print_error "Invalid option"
            pause_menu
            show_utilities_menu
            ;;
    esac
}

# ============================================================================
# DOCUMENTATION MENU
# ============================================================================
show_documentation_menu() {
    clear_screen
    print_header
    
    print_menu_header "DOCUMENTATION"
    
    echo "1) Display RHIS Integration Summary  - Complete integration overview"
    echo "2) Display RHIS Builder Integration  - Builder component details"
    echo "3) Display RHIS Migration Guide      - Migration instructions"
    echo "4) Display Inventory Integration     - Inventory integration details"
    echo "5) Display Inventory Integration Gde - Inventory integration guide"
    echo "6) Display RHIS Quick Reference      - Quick reference guide"
    echo "7) Open Project README               - Main project documentation"
    echo "8) Open Main Documentation          - Primary documentation files"
    echo "9) List All Documentation Files      - Show all available docs"
    echo ""
    echo "0) Back to Main Menu"
    echo ""
    read -p "Select option (0-9): " doc_choice
    
    case "$doc_choice" in
        1) 
            if [ -f "${PROJECT_ROOT}/RHIS_COMPLETE_INTEGRATION_SUMMARY.md" ]; then
                less "${PROJECT_ROOT}/RHIS_COMPLETE_INTEGRATION_SUMMARY.md"
            else
                print_error "File not found"
            fi
            show_documentation_menu
            ;;
        2) 
            if [ -f "${PROJECT_ROOT}/doc/RHIS_INTEGRATION_PLAN.md" ]; then
                less "${PROJECT_ROOT}/doc/RHIS_INTEGRATION_PLAN.md"
            else
                print_error "File not found"
            fi
            show_documentation_menu
            ;;
        3) 
            if [ -f "${PROJECT_ROOT}/doc/RHIS_MIGRATION_GUIDE.md" ]; then
                less "${PROJECT_ROOT}/doc/RHIS_MIGRATION_GUIDE.md"
            else
                print_error "File not found"
            fi
            show_documentation_menu
            ;;
        4) 
            if [ -f "${PROJECT_ROOT}/doc/RHIS_INVENTORY_INTEGRATION_PLAN.md" ]; then
                less "${PROJECT_ROOT}/doc/RHIS_INVENTORY_INTEGRATION_PLAN.md"
            else
                print_error "File not found"
            fi
            show_documentation_menu
            ;;
        5) 
            if [ -f "${PROJECT_ROOT}/doc/RHIS_INVENTORY_INTEGRATION_GUIDE.md" ]; then
                less "${PROJECT_ROOT}/doc/RHIS_INVENTORY_INTEGRATION_GUIDE.md"
            else
                print_error "File not found"
            fi
            show_documentation_menu
            ;;
        6) 
            if [ -f "${PROJECT_ROOT}/RHIS_QUICK_REFERENCE.md" ]; then
                less "${PROJECT_ROOT}/RHIS_QUICK_REFERENCE.md"
            else
                print_error "File not found"
            fi
            show_documentation_menu
            ;;
        7) 
            if [ -f "${PROJECT_ROOT}/README.md" ]; then
                less "${PROJECT_ROOT}/README.md"
            else
                print_error "README not found"
            fi
            show_documentation_menu
            ;;
        8) 
            if [ -f "${PROJECT_ROOT}/doc/README.md" ]; then
                less "${PROJECT_ROOT}/doc/README.md"
            else
                print_error "Documentation not found"
            fi
            show_documentation_menu
            ;;
        9) 
            print_info "Documentation Files:"
            echo ""
            find "${PROJECT_ROOT}/doc" -type f -name "*.md" 2>/dev/null | sed 's|.*doc/||' | sort
            echo ""
            find "${PROJECT_ROOT}" -maxdepth 1 -type f -name "*RHIS*.md" 2>/dev/null | sed 's|.*||g' | sort
            pause_menu
            show_documentation_menu
            ;;
        0) 
            show_main_menu
            ;;
        *) 
            print_error "Invalid option"
            pause_menu
            show_documentation_menu
            ;;
    esac
}

# ============================================================================
# NETWORK BOOT SERVICES MENU (TFTP Server)
# ============================================================================
show_network_boot_menu() {
    clear_screen
    print_header
    
    print_menu_header "NETWORK BOOT SERVICES"
    
    echo "Configure and manage TFTP boot server for network-based OS installations"
    echo ""
    echo "1) Setup TFTP Boot Server            - Configure TFTP for ISO and OEMDRV"
    echo "2) Check TFTP Server Status          - View server status and files"
    echo "3) Sync Files from Project           - Copy ISO/OEMDRV from files/ to TFTP"
    echo "4) View TFTP Configuration           - Display server configuration"
    echo "5) Start/Restart TFTP Service        - Control tftp.socket service"
    echo "6) View Boot Menu                    - Display PXE boot menu configuration"
    echo ""
    echo "0) Back to Main Menu"
    echo ""
    read -p "Select option (0-6): " network_boot_choice
    
    case "$network_boot_choice" in
        1) 
            print_info "Setting up TFTP Boot Server..."
            run_playbook "playbooks/tftp_boot_server-setup.yml"
            print_success "TFTP Boot Server setup complete"
            pause_menu
            show_network_boot_menu
            ;;
        2) 
            print_info "TFTP Server Status:"
            echo ""
            if command -v tftp-server-status &> /dev/null; then
                tftp-server-status
            else
                systemctl status tftp.socket 2>/dev/null || print_error "TFTP not running or not installed"
            fi
            pause_menu
            show_network_boot_menu
            ;;
        3) 
            print_info "Syncing ISO and OEMDRV files to TFTP server..."
            if command -v tftp-sync-files &> /dev/null; then
                tftp-sync-files "${PROJECT_ROOT}"
            else
                echo "tftp-sync-files command not found. Running manual sync..."
                if [ -d "${PROJECT_ROOT}/files" ]; then
                    echo "Copying ISO files..."
                    cp -v "${PROJECT_ROOT}"/files/*.iso /var/lib/tftpboot/iso/ 2>/dev/null || print_error "No ISO files found"
                    echo "Copying OEMDRV files..."
                    cp -v "${PROJECT_ROOT}"/files/OEMDRV* /var/lib/tftpboot/ 2>/dev/null || echo "No OEMDRV files found"
                else
                    print_error "Project files directory not found: ${PROJECT_ROOT}/files"
                fi
            fi
            print_success "File sync complete"
            pause_menu
            show_network_boot_menu
            ;;
        4) 
            print_info "TFTP Server Configuration:"
            echo ""
            echo "TFTP Root:           /var/lib/tftpboot"
            echo "Service:             tftp.socket (xinetd)"
            echo "Port:                69/UDP"
            echo ""
            if [ -f /var/lib/tftpboot/pxelinux.cfg/default ]; then
                echo "PXE Configuration File Contents:"
                echo ""
                cat /var/lib/tftpboot/pxelinux.cfg/default
            else
                print_error "PXE configuration not found (server may not be configured yet)"
            fi
            pause_menu
            show_network_boot_menu
            ;;
        5) 
            print_info "Managing TFTP Service..."
            echo ""
            echo "1) Start TFTP"
            echo "2) Stop TFTP"
            echo "3) Restart TFTP"
            echo "4) Enable TFTP (auto-start)"
            echo "5) Disable TFTP"
            echo ""
            read -p "Select action (1-5): " service_action
            case "$service_action" in
                1) systemctl start tftp.socket && print_success "TFTP started" || print_error "Failed to start TFTP" ;;
                2) systemctl stop tftp.socket && print_success "TFTP stopped" || print_error "Failed to stop TFTP" ;;
                3) systemctl restart tftp.socket && print_success "TFTP restarted" || print_error "Failed to restart TFTP" ;;
                4) systemctl enable tftp.socket && print_success "TFTP enabled for auto-start" || print_error "Failed to enable TFTP" ;;
                5) systemctl disable tftp.socket && print_success "TFTP disabled" || print_error "Failed to disable TFTP" ;;
                *) print_error "Invalid action" ;;
            esac
            pause_menu
            show_network_boot_menu
            ;;
        6) 
            print_info "PXE Boot Menu:"
            echo ""
            if [ -f /var/lib/tftpboot/index.html ]; then
                echo "Boot menu is available at: http://$(hostname -I | awk '{print $1}')/"
                echo ""
                echo "Available boot options:"
                grep "LABEL" /var/lib/tftpboot/pxelinux.cfg/default 2>/dev/null | while read line; do
                    echo "  $line"
                done
            else
                print_error "Boot menu not configured (run Setup TFTP Boot Server first)"
            fi
            pause_menu
            show_network_boot_menu
            ;;
        0) 
            show_main_menu
            ;;
        *) 
            print_error "Invalid option"
            pause_menu
            show_network_boot_menu
            ;;
    esac
}

# ============================================================================
# INITIALIZE RED HAT CREDENTIALS
# ============================================================================
initialize_credentials() {
    local env_file="${HOME}/.ansible/conf/env.yml"
    local env_dir="$(dirname "$env_file")"
    
    # Create directory if it doesn't exist
    if [ ! -d "$env_dir" ]; then
        mkdir -p "$env_dir"
        chmod 700 "$env_dir"
    fi
    
    # Create env.yml if it doesn't exist
    if [ ! -f "$env_file" ]; then
        clear_screen
        print_header
        print_menu_header "RED HAT CREDENTIALS INITIALIZATION"
        echo ""
        echo "First-time setup: Red Hat credentials are required for:"
        echo "  • Red Hat CDN access (all rhel.com domains)"
        echo "  • System registration (non-Satellite managed systems)"
        echo "  • registry.redhat.io access for container images"
        echo "  • Automation Hub API tokens"
        echo ""
        echo "Visit https://console.redhat.com/api/automation-hub/token/ for your token"
        echo ""
        
        # Prompt for credentials
        read -p "Red Hat username (email/SSO): " redhat_user
        read -sp "Red Hat password: " redhat_password
        echo ""
        read -p "Red Hat Automation Hub token: " redhat_token
        echo ""
        
        # Create env.yml with credentials
        cat > "$env_file" << EOF
---
# Red Hat Credentials - auto-generated $(date '+%Y-%m-%d %H:%M:%S')
# Required for CDN access, registry authentication, and API tokens

redhat_user: "$redhat_user"
redhat_password: "$redhat_password"
redhat_token: "$redhat_token"

# These credentials are used for:
# - All rhel.com domain authentication
# - Red Hat CDN access for system registration
# - registry.redhat.io authentication
# - Ansible Automation Hub API access
# - ansible.cfg.j2 template rendering
EOF
        chmod 600 "$env_file"
        print_success "Red Hat credentials saved to $env_file"
        pause_menu
    else
        # Check if credentials exist in env.yml
        local needs_update=false
        
        # Check for redhat_user
        if ! grep -q "^redhat_user:" "$env_file" || grep "^redhat_user:.*null\|^redhat_user: \"\"" "$env_file" >/dev/null 2>&1; then
            needs_update=true
        fi
        
        # Check for redhat_password
        if ! grep -q "^redhat_password:" "$env_file" || grep "^redhat_password:.*null\|^redhat_password: \"\"" "$env_file" >/dev/null 2>&1; then
            needs_update=true
        fi
        
        # Check for redhat_token
        if ! grep -q "^redhat_token:" "$env_file" || grep "^redhat_token:.*null\|^redhat_token: \"\"" "$env_file" >/dev/null 2>&1; then
            needs_update=true
        fi
        
        # If any credential is missing, prompt for update
        if [ "$needs_update" = true ]; then
            clear_screen
            print_header
            print_menu_header "RED HAT CREDENTIALS UPDATE"
            echo ""
            echo "Some Red Hat credentials are missing or incomplete."
            echo "Credentials are needed for CDN access and API authentication."
            echo ""
            
            # Prompt for missing credentials
            read -p "Red Hat username (email/SSO): " redhat_user
            read -sp "Red Hat password: " redhat_password
            echo ""
            read -p "Red Hat Automation Hub token: " redhat_token
            echo ""
            
            # Update env.yml
            cat > "$env_file" << EOF
---
# Red Hat Credentials - updated $(date '+%Y-%m-%d %H:%M:%S')
# Required for CDN access, registry authentication, and API tokens

redhat_user: "$redhat_user"
redhat_password: "$redhat_password"
redhat_token: "$redhat_token"

# These credentials are used for:
# - All rhel.com domain authentication
# - Red Hat CDN access for system registration
# - registry.redhat.io authentication
# - Ansible Automation Hub API access
# - ansible.cfg.j2 template rendering
EOF
            chmod 600 "$env_file"
            print_success "Red Hat credentials updated in $env_file"
            pause_menu
        fi
    fi
    
    # Export credentials as environment variables for use in scripts and templates
    if [ -f "$env_file" ]; then
        export REDHAT_USER=$(grep "^redhat_user:" "$env_file" | awk '{print $2}' | tr -d '"')
        export REDHAT_PASSWORD=$(grep "^redhat_password:" "$env_file" | awk '{print $2}' | tr -d '"')
        export REDHAT_TOKEN=$(grep "^redhat_token:" "$env_file" | awk '{print $2}' | tr -d '"')
        # Export as ansible-galaxy environment variables (proper Ansible mechanism)
        export ANSIBLE_GALAXY_SERVER_PUBLISHED_TOKEN="$REDHAT_TOKEN"
        export ANSIBLE_GALAXY_SERVER_VALIDATED_TOKEN="$REDHAT_TOKEN"
        # Also export for backward compatibility
        export REDHAT_HUB_TOKEN="$REDHAT_TOKEN"
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
main() {
    # Do NOT initialize credentials automatically. The installer provides
    # an explicit menu option to configure local credentials so personal
    # secrets remain local and are only created or modified by operator action.
    while true; do
        show_main_menu
    done
}

# Run main function
main "$@"
