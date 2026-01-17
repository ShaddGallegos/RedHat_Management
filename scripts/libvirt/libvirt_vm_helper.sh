#!/bin/bash
#
# libvirt_vm_helper.sh - Helper utilities for Libvirt VM management
# Provides quick commands for VM management
#

set -e

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
usage() {
    cat << EOF
Libvirt VM Helper - Quick VM Management

Usage: $(basename "$0") <command> [options]

Commands:
    list                List all VMs
    info <vm-name>      Show VM information
    console <vm-name>   Connect to VM console (Ctrl+] to exit)
    ip <vm-name>        Get VM IP address
    start <vm-name>     Start a VM
    stop <vm-name>      Stop a VM
    delete <vm-name>    Delete a VM
    clone <src> <dst>   Clone a VM
    resize <vm> <size>  Resize VM disk
    snapshot <vm>       Create VM snapshot
    revert <vm> <snap>  Revert to snapshot
    help                Show this help

Examples:
    $(basename "$0") list
    $(basename "$0") console rhel10-vm
    $(basename "$0") ip rhel10-vm
    $(basename "$0") clone rhel10-vm rhel10-vm-copy
    $(basename "$0") resize rhel10-vm 100G

EOF
    exit 0
}

# List VMs
list_vms() {
    echo -e "${BLUE}Virtual Machines:${NC}"
    echo ""
    virsh list --all --name | while read vm; do
        if [ -n "$vm" ]; then
            state=$(virsh domstate "$vm" 2>/dev/null || echo "error")
            printf "  %-30s %s\n" "$vm" "$state"
        fi
    done
    echo ""
}

# VM Info
vm_info() {
    local vm=$1
    if [ -z "$vm" ]; then
        echo -e "${RED}ERROR: VM name required${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}VM Information: $vm${NC}"
    echo ""
    virsh dominfo "$vm"
    echo ""
    
    echo -e "${BLUE}VM Network:${NC}"
    virsh domifaddr "$vm" 2>/dev/null || echo "  Not connected"
    echo ""
}

# Console
vm_console() {
    local vm=$1
    if [ -z "$vm" ]; then
        echo -e "${RED}ERROR: VM name required${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Connecting to console of $vm${NC}"
    echo "Press Ctrl+] to exit"
    echo ""
    virsh console "$vm"
}

# Get IP
vm_ip() {
    local vm=$1
    if [ -z "$vm" ]; then
        echo -e "${RED}ERROR: VM name required${NC}"
        exit 1
    fi
    
    local ip=$(virsh domifaddr "$vm" 2>/dev/null | grep ipv4 | awk '{print $2}' | cut -d/ -f1)
    if [ -n "$ip" ]; then
        echo -e "${GREEN}$ip${NC}"
    else
        echo -e "${RED}No IP address found${NC}"
        exit 1
    fi
}

# Start VM
vm_start() {
    local vm=$1
    if [ -z "$vm" ]; then
        echo -e "${RED}ERROR: VM name required${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Starting $vm...${NC}"
    virsh start "$vm"
    echo -e "${GREEN}[SUCCESS] VM started${NC}"
}

# Stop VM
vm_stop() {
    local vm=$1
    if [ -z "$vm" ]; then
        echo -e "${RED}ERROR: VM name required${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Stopping $vm...${NC}"
    virsh shutdown "$vm"
    echo -e "${GREEN}[SUCCESS] Shutdown signal sent${NC}"
}

# Delete VM
vm_delete() {
    local vm=$1
    if [ -z "$vm" ]; then
        echo -e "${RED}ERROR: VM name required${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Deleting $vm...${NC}"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        virsh undefine "$vm" --remove-all-storage
        echo -e "${GREEN}[SUCCESS] VM deleted${NC}"
    else
        echo "Cancelled"
    fi
}

# Clone VM
vm_clone() {
    local src=$1
    local dst=$2
    
    if [ -z "$src" ] || [ -z "$dst" ]; then
        echo -e "${RED}ERROR: Source and destination VM names required${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Cloning $src to $dst...${NC}"
    virt-clone --original "$src" --name "$dst"
    echo -e "${GREEN}[SUCCESS] VM cloned${NC}"
}

# Resize disk
vm_resize() {
    local vm=$1
    local size=$2
    
    if [ -z "$vm" ] || [ -z "$size" ]; then
        echo -e "${RED}ERROR: VM name and size required${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Resizing disk of $vm to $size...${NC}"
    local disk="/var/lib/libvirt/images/${vm}.qcow2"
    
    if [ ! -f "$disk" ]; then
        echo -e "${RED}ERROR: Disk file not found: $disk${NC}"
        exit 1
    fi
    
    virsh blockresize "$vm" "$disk" "$size"
    echo -e "${GREEN}[SUCCESS] Disk resized${NC}"
}

# Create snapshot
vm_snapshot() {
    local vm=$1
    if [ -z "$vm" ]; then
        echo -e "${RED}ERROR: VM name required${NC}"
        exit 1
    fi
    
    local snap_name="${vm}-snap-$(date +%s)"
    echo -e "${YELLOW}Creating snapshot $snap_name...${NC}"
    virsh snapshot-create-as "$vm" "$snap_name"
    echo -e "${GREEN}[SUCCESS] Snapshot created: $snap_name${NC}"
}

# Revert snapshot
vm_revert() {
    local vm=$1
    local snap=$2
    
    if [ -z "$vm" ] || [ -z "$snap" ]; then
        echo -e "${RED}ERROR: VM name and snapshot name required${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Reverting $vm to snapshot $snap...${NC}"
    virsh snapshot-revert "$vm" "$snap"
    echo -e "${GREEN}[SUCCESS] Reverted to snapshot${NC}"
}

# Main
if [ $# -eq 0 ]; then
    usage
fi

command=$1
shift

case "$command" in
    list)
        list_vms
        ;;
    info)
        vm_info "$@"
        ;;
    console)
        vm_console "$@"
        ;;
    ip)
        vm_ip "$@"
        ;;
    start)
        vm_start "$@"
        ;;
    stop)
        vm_stop "$@"
        ;;
    delete)
        vm_delete "$@"
        ;;
    clone)
        vm_clone "$@"
        ;;
    resize)
        vm_resize "$@"
        ;;
    snapshot)
        vm_snapshot "$@"
        ;;
    revert)
        vm_revert "$@"
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo -e "${RED}Unknown command: $command${NC}"
        usage
        ;;
esac
