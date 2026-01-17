#!/bin/bash
# validate-reorganization.sh
# Validates the role reorganization is complete and correct

set -euo pipefail

ROLES_DIR="/run/media/sgallego/SD_Card/GIT/RedHat_Management/roles"
PASS=0
FAIL=0

echo ""
echo "        RedHat_Management Role Reorganization Validator             "
echo ""
echo ""

# Function to check role exists
check_role() {
    local role_path="$1"
    local role_name="$2"
    
    if [ -d "${ROLES_DIR}/${role_path}" ]; then
        echo " ${role_name}"
        ((PASS++))
    else
        echo " ${role_name} - MISSING"
        ((FAIL++))
    fi
}

# Function to check task file exists
check_task() {
    local role_path="$1"
    local task_file="$2"
    
    if [ -f "${ROLES_DIR}/${role_path}/tasks/${task_file}" ]; then
        echo "   ${task_file}"
        ((PASS++))
    else
        echo "   ${task_file} - MISSING"
        ((FAIL++))
    fi
}

echo "OS-Level Roles"
echo ""
check_role "os/rhel_base" "RHEL Base"
check_task "os/rhel_base" "main.yml"
check_role "os/rhel_updates" "RHEL Updates"
check_task "os/rhel_updates" "main.yml"
check_role "os/ssh_hardening" "SSH Hardening"
check_task "os/ssh_hardening" "main.yml"
check_role "os/firewall_base" "Firewall Base"
check_task "os/firewall_base" "main.yml"
check_role "os/selinux_config" "SELinux Config"
check_task "os/selinux_config" "main.yml"
echo ""

echo "Infrastructure Roles"
echo ""
check_role "infrastructure/libvirt" "Libvirt"
check_task "infrastructure/libvirt" "main.yml"
check_task "infrastructure/libvirt" "install.yml"
check_task "infrastructure/libvirt" "network.yml"
check_task "infrastructure/libvirt" "storage.yml"

check_role "infrastructure/cloud/aws" "AWS Cloud"
check_task "infrastructure/cloud/aws" "main.yml"
check_role "infrastructure/cloud/azure" "Azure Cloud"
check_task "infrastructure/cloud/azure" "main.yml"
check_role "infrastructure/cloud/vmware" "VMware"
check_task "infrastructure/cloud/vmware" "main.yml"
check_role "infrastructure/cloud/nutanix" "Nutanix"
check_task "infrastructure/cloud/nutanix" "main.yml"

check_role "infrastructure/container/openshift" "OpenShift"
check_task "infrastructure/container/openshift" "main.yml"
echo ""

echo "Red Hat Products - Satellite"
echo ""
check_role "redhat_products/satellite/satellite_base" "Satellite Base"
check_task "redhat_products/satellite/satellite_base" "main.yml"
check_role "redhat_products/satellite/satellite_api" "Satellite API"
check_task "redhat_products/satellite/satellite_api" "main.yml"
check_role "redhat_products/satellite/satellite_content" "Satellite Content (skeleton)"
check_role "redhat_products/satellite/satellite_hosts" "Satellite Hosts (skeleton)"
check_role "redhat_products/satellite/satellite_reporting" "Satellite Reporting (skeleton)"
echo ""

echo "Red Hat Products - AAP"
echo ""
check_role "redhat_products/aap/aap_base" "AAP Base"
check_task "redhat_products/aap/aap_base" "main.yml"
check_role "redhat_products/aap/aap_callbacks" "AAP Callbacks"
check_task "redhat_products/aap/aap_callbacks" "main.yml"
check_role "redhat_products/aap/aap_rbac" "AAP RBAC (skeleton)"
check_role "redhat_products/aap/aap_eda" "AAP EDA (skeleton)"
echo ""

echo "Red Hat Products - IDM & Insights"
echo ""
check_role "redhat_products/idm/idm_base" "IDM Base (skeleton)"
check_role "redhat_products/idm/idm_integration" "IDM Integration (skeleton)"
check_role "redhat_products/insights/insights_base" "Insights Base (skeleton)"
check_role "redhat_products/insights/insights_rhc" "Insights RHC (skeleton)"
check_role "redhat_products/insights/insights_remediation" "Insights Remediation (skeleton)"
echo ""

echo "Integration Roles"
echo ""
check_role "integration/satellite_aap" "Satellite-AAP"
check_task "integration/satellite_aap" "main.yml"
check_role "integration/satellite_idm" "Satellite-IDM"
check_task "integration/satellite_idm" "main.yml"
check_role "integration/satellite_insights" "Satellite-Insights"
check_task "integration/satellite_insights" "main.yml"
check_role "integration/servicenow" "ServiceNow"
check_task "integration/servicenow" "main.yml"
echo ""

echo "Support Roles"
echo ""
check_role "support/preflight_tests" "Preflight Tests"
check_task "support/preflight_tests" "main.yml"
check_role "support/ansible_cmdb_setup" "CMDB Setup"
check_task "support/ansible_cmdb_setup" "main.yml"
check_role "support/backup_restore" "Backup/Restore"
check_task "support/backup_restore" "main.yml"
echo ""

echo "Playbook Updates"
echo ""
if grep -q "redhat_products/satellite/satellite_base" /run/media/sgallego/SD_Card/GIT/RedHat_Management/redhat_management-site.yml; then
    echo " Playbook references updated"
    ((PASS++))
else
    echo " Playbook references NOT updated"
    ((FAIL++))
fi

if [ -f /run/media/sgallego/SD_Card/GIT/RedHat_Management/ROLE_RESTRUCTURE.md ]; then
    echo " ROLE_RESTRUCTURE.md documentation created"
    ((PASS++))
else
    echo " ROLE_RESTRUCTURE.md documentation MISSING"
    ((FAIL++))
fi

if [ -f /run/media/sgallego/SD_Card/GIT/RedHat_Management/REORGANIZATION_COMPLETE.md ]; then
    echo " REORGANIZATION_COMPLETE.md created"
    ((PASS++))
else
    echo " REORGANIZATION_COMPLETE.md MISSING"
    ((FAIL++))
fi

if [ -d /run/media/sgallego/SD_Card/GIT/RedHat_Management/playbooks/archived ]; then
    echo " Legacy playbooks archived"
    ((PASS++))
else
    echo " Legacy playbooks NOT archived"
    ((FAIL++))
fi

if [ -d /run/media/sgallego/SD_Card/GIT/RedHat_Management/roles.backup.* ]; then
    echo " Old roles backed up"
    ((PASS++))
else
    echo " Old roles backup NOT found"
    ((FAIL++))
fi

echo ""
echo ""
echo "                         Validation Results                        "
echo ""
echo ""
echo "   Passed: $PASS"
echo "   Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo " All validation checks passed!"
    echo ""
    echo "Next steps:"
    echo "  1. Run: ansible-lint redhat_management-site.yml"
    echo "  2. Test: ansible-playbook -i inventory redhat_management-site.yml --check"
    echo "  3. Review: ROLE_RESTRUCTURE.md for usage information"
    exit 0
else
    echo "⚠  Some validation checks failed. Review above."
    exit 1
fi
