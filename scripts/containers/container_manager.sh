#!/bin/bash
#
# container_manager.sh - Unified container management utility
# Consolidates: update_containers.sh, run_container.sh, export_rhis_container.sh
#
# Usage: container_manager.sh <command> [options]
#   pull              - Pull and tag containers from remote registry
#   run               - Run container with mounted directories
#   export [version]  - Export container to tar archive
#   help              - Show this help message

set -euo pipefail

REGISTRY="quay.io"
REPO="parmstro"
ANSIBLE_VER="2.4"

# ============================================================================
# PULL AND TAG CONTAINERS
# ============================================================================
cmd_pull() {
    local version="${1:-}"
    
    if [[ -z "$version" ]]; then
        # Pull and tag both 2.4 and 2.5 versions
        echo "Pulling RHIS provisioner containers..."
        podman pull ${REGISTRY}/${REPO}/rhis-provisioner-9-2.4:latest
        podman tag ${REGISTRY}/${REPO}/rhis-provisioner-9-2.4:latest localhost/rhis-provisioner-9-2.4:latest
        podman pull ${REGISTRY}/${REPO}/rhis-provisioner-9-2.5:latest
        podman tag ${REGISTRY}/${REPO}/rhis-provisioner-9-2.5:latest localhost/rhis-provisioner-9-2.5:latest
        echo "✓ All containers refreshed!"
    else
        # Pull specific version
        echo "Pulling RHIS provisioner-9-${version}..."
        podman pull ${REGISTRY}/${REPO}/rhis-provisioner-9-${version}:latest
        podman tag ${REGISTRY}/${REPO}/rhis-provisioner-9-${version}:latest localhost/rhis-provisioner-9-${version}:latest
        echo "✓ Container ${version} refreshed!"
    fi
}

# ============================================================================
# RUN CONTAINER WITH MOUNTS
# ============================================================================
cmd_run() {
    local ansible_ver="2.4"
    local ext_tasks_dir=""
    local files_dir=""
    local group_vars_dir=""
    local host_vars_dir=""
    local inventory_dir=""
    local secrets_dir=""
    local templates_dir=""
    local vars_dir=""
    local ssh_dir=""
    local registry_url="$REGISTRY"
    local repo_url="$REPO"
    
    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -a|--ansible-ver)
                ansible_ver="$2"
                shift 2
                ;;
            -e|--external-tasks-dir)
                ext_tasks_dir="$2"
                shift 2
                ;;
            -f|--files-dir)
                files_dir="$2"
                shift 2
                ;;
            -g|--group-vars-dir)
                group_vars_dir="$2"
                shift 2
                ;;
            -h|--host-vars-dir)
                host_vars_dir="$2"
                shift 2
                ;;
            -i|--inventory-dir)
                inventory_dir="$2"
                shift 2
                ;;
            -r|--container-registry)
                registry_url="$2"
                shift 2
                ;;
            -R|--container-repo)
                repo_url="$2"
                shift 2
                ;;
            -s|--secrets-dir)
                secrets_dir="$2"
                shift 2
                ;;
            -t|--templates-dir)
                templates_dir="$2"
                shift 2
                ;;
            -v|--vars-dir)
                vars_dir="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    echo "Launching rhis-provisioner container..."
    echo "  external-tasks-dir: $ext_tasks_dir"
    echo "  files-dir: $files_dir"
    echo "  group-vars-dir: $group_vars_dir"
    echo "  host-vars-dir: $host_vars_dir"
    echo "  inventory-dir: $inventory_dir"
    echo "  secrets-dir: $secrets_dir"
    echo "  templates-dir: $templates_dir"
    echo "  vars-dir: $vars_dir"
    echo "  ansible-ver: $ansible_ver"
    echo
    
    # Validation
    if [[ -z "$secrets_dir" ]]; then
        echo "ERROR: A secrets directory is required (--secrets-dir)"
        exit 1
    fi
    
    if [[ -z "$group_vars_dir" || -z "$host_vars_dir" || -z "$inventory_dir" ]]; then
        echo "ERROR: group-vars-dir, host-vars-dir, and inventory-dir are required"
        exit 1
    fi
    
    # Build registry path
    if [[ "$repo_url" == "" ]]; then
        registry_path="$registry_url"
    else
        registry_path="${registry_url}/${repo_url}"
    fi
    
    # Build mount options
    local mounts="-v ${inventory_dir}:/rhis/vars/external_inventory:Z"
    [[ -n "$ext_tasks_dir" ]] && mounts="${mounts} -v ${ext_tasks_dir}:/rhis/vars/external_tasks:Z"
    [[ -n "$files_dir" ]] && mounts="${mounts} -v ${files_dir}:/rhis/vars/files:Z"
    [[ -n "$group_vars_dir" ]] && mounts="${mounts} -v ${group_vars_dir}:/rhis/vars/group_vars:Z"
    [[ -n "$host_vars_dir" ]] && mounts="${mounts} -v ${host_vars_dir}:/rhis/vars/host_vars:Z"
    [[ -n "$templates_dir" ]] && mounts="${mounts} -v ${templates_dir}:/rhis/vars/templates:Z"
    [[ -n "$vars_dir" ]] && mounts="${mounts} -v ${vars_dir}:/rhis/vars/vars:Z"
    [[ -n "$secrets_dir" ]] && mounts="${mounts} -v ${secrets_dir}:/rhis/vars/vault:Z"
    
    # Run container
    eval "podman run -it ${mounts} --hostname provisioner ${registry_path}/rhis-provisioner-9-${ansible_ver}:latest"
    
    # Restore SELinux context
    echo "Restoring SELinux context..."
    [[ -n "$ext_tasks_dir" ]] && restorecon -FRq "$ext_tasks_dir" 2>/dev/null || true
    [[ -n "$files_dir" ]] && restorecon -FRq "$files_dir" 2>/dev/null || true
    [[ -n "$group_vars_dir" ]] && restorecon -FRq "$group_vars_dir" 2>/dev/null || true
    [[ -n "$host_vars_dir" ]] && restorecon -FRq "$host_vars_dir" 2>/dev/null || true
    [[ -n "$inventory_dir" ]] && restorecon -FRq "$inventory_dir" 2>/dev/null || true
    [[ -n "$secrets_dir" ]] && restorecon -FRq "$secrets_dir" 2>/dev/null || true
    [[ -n "$templates_dir" ]] && restorecon -FRq "$templates_dir" 2>/dev/null || true
    [[ -n "$vars_dir" ]] && restorecon -FRq "$vars_dir" 2>/dev/null || true
}

# ============================================================================
# EXPORT CONTAINER TO TAR ARCHIVE
# ============================================================================
cmd_export() {
    local version="${1:-2.4}"
    local pull_registry="$REGISTRY"
    local pull_repo="$REPO"
    local pull_login=""
    local pull_token=""
    
    # Parse arguments
    local shift_count=1
    while [[ $shift_count -lt $# ]]; do
        case "${!shift_count}" in
            -p|--pull-registry)
                ((shift_count++))
                pull_registry="${!shift_count}"
                ;;
            -r|--pull-registry-repo)
                ((shift_count++))
                pull_repo="${!shift_count}"
                ;;
            -u|--pull-registry-login)
                ((shift_count++))
                pull_login="${!shift_count}"
                ;;
            -t|--pull-registry-token)
                ((shift_count++))
                pull_token="${!shift_count}"
                ;;
        esac
        ((shift_count++))
    done
    
    # Validate version
    if [[ ! "$version" =~ ^(2\.4|2\.5)$ ]]; then
        echo "ERROR: Unsupported ansible version. Select 2.4 or 2.5"
        exit 2
    fi
    
    local output_file="./rhis-provisioner-9-${version}-latest.tar"
    
    # Check if output file exists
    if [[ -f "$output_file" ]]; then
        echo "Archive exists: $output_file"
        read -p "Overwrite? (Y/n): " overwrite
        if [[ "$overwrite" != "Y" && "$overwrite" != "y" && "$overwrite" != "" ]]; then
            exit 0
        fi
        echo "Overwriting..."
        rm -f "$output_file"
    fi
    
    # Pull container or use local
    if [[ "$pull_registry" == "localhost" ]]; then
        pull_location="localhost"
    else
        pull_location="${pull_registry}/${pull_repo}"
        echo "Pulling ${pull_location}/rhis-provisioner-9-${version}:latest..."
        
        if [[ -n "$pull_login" && -n "$pull_token" ]]; then
            podman login -u "$pull_login" -p "$pull_token" "$pull_registry"
        fi
        
        podman pull "${pull_location}/rhis-provisioner-9-${version}:latest"
    fi
    
    # Export to tar
    local container_src="${pull_location}/rhis-provisioner-9-${version}:latest"
    echo "Archiving container to tarfile: $output_file"
    buildah push "$container_src" "docker-archive:${output_file}"
    echo "✓ Container archived successfully!"
}

# ============================================================================
# HELP
# ============================================================================
usage() {
    cat << EOF
Container Manager - Unified container management utility

Usage: $(basename "$0") <command> [options]

Commands:
    pull [version]          Pull and tag containers
                            If version omitted, pulls both 2.4 and 2.5
    
    run                     Run container with mounted directories
      Options:
        -a, --ansible-ver VERSION       Ansible version (default: 2.4)
        -e, --external-tasks-dir DIR    External tasks directory
        -f, --files-dir DIR             Files directory
        -g, --group-vars-dir DIR        Group vars directory (required)
        -h, --host-vars-dir DIR         Host vars directory (required)
        -i, --inventory-dir DIR         Inventory directory (required)
        -r, --container-registry REG    Container registry (default: quay.io)
        -R, --container-repo REPO       Container repo (default: parmstro)
        -s, --secrets-dir DIR           Secrets directory (required)
        -t, --templates-dir DIR         Templates directory
        -v, --vars-dir DIR              Vars directory
    
    export [version]        Export container to tar archive
      Default version: 2.4
      Options:
        -p, --pull-registry REG         Pull registry (default: quay.io)
        -r, --pull-registry-repo REPO   Pull repo (default: parmstro)
        -u, --pull-registry-login USER  Registry login
        -t, --pull-registry-token TOKEN Registry token

Examples:
    # Pull both versions
    $(basename "$0") pull
    
    # Pull specific version
    $(basename "$0") pull 2.5
    
    # Run container
    $(basename "$0") run -g /path/to/group_vars -h /path/to/host_vars \\
                        -i /path/to/inventory -s /path/to/secrets
    
    # Export container
    $(basename "$0") export 2.4

EOF
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    if [[ $# -lt 1 ]]; then
        usage
        exit 1
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        pull)
            cmd_pull "$@"
            ;;
        run)
            cmd_run "$@"
            ;;
        export)
            cmd_export "$@"
            ;;
        help|-h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

main "$@"
