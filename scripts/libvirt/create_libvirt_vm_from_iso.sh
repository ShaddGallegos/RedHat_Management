#!/bin/bash
#
# create_libvirt_vm_from_iso.sh
# Creates a RHEL VM on Libvirt using ISO and Kickstart
#
# Usage: ./create_libvirt_vm_from_iso.sh --name vm-name --cpus 4 --memory 8192 --disk 50
#

set -e

# Default values
VM_NAME="rhel10-vm"
VM_CPUS=2
VM_MEMORY=2048
VM_DISK=50
VM_NETWORK="default"
ISO_FILE=""
KICKSTART_FILE=""
BRIDGE_DEVICE=""
MAC_ADDRESS=""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    --name NAME              VM name (default: rhel10-vm)
    --cpus N                 Number of vCPUs (default: 2)
    --memory MB              RAM in MB (default: 2048)
    --disk SIZE              Disk size in GB (default: 50)
    --iso FILE               ISO file path (default: files/rhel-10.iso)
    --kickstart FILE         Kickstart file (default: files/oem.cfg)
    --network NETWORK        Network to attach (default: default)
    --bridge DEVICE          Bridge device (optional, e.g., br0)
    --mac ADDRESS            MAC address (optional, auto-generated if not specified)
    --help                   Show this help message

EXAMPLE:
    $0 --name prod-server --cpus 4 --memory 8192 --disk 100

PREREQUISITES:
    - ISO file in files/rhel-10.iso
    - Kickstart file in files/oem.cfg
    - Libvirt daemon running (systemctl status libvirtd)
    - Storage pool configured (virsh pool-list)

EOF
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            VM_NAME="$2"
            shift 2
            ;;
        --cpus)
            VM_CPUS="$2"
            shift 2
            ;;
        --memory)
            VM_MEMORY="$2"
            shift 2
            ;;
        --disk)
            VM_DISK="$2"
            shift 2
            ;;
        --iso)
            ISO_FILE="$2"
            shift 2
            ;;
        --kickstart)
            KICKSTART_FILE="$2"
            shift 2
            ;;
        --network)
            VM_NETWORK="$2"
            shift 2
            ;;
        --bridge)
            BRIDGE_DEVICE="$2"
            shift 2
            ;;
        --mac)
            MAC_ADDRESS="$2"
            shift 2
            ;;
        --help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Set defaults if not provided
ISO_FILE="${ISO_FILE:-files/rhel-10.iso}"
KICKSTART_FILE="${KICKSTART_FILE:-files/oem.cfg}"

# Validate prerequisites
validate_prerequisites() {
    echo -e "${YELLOW}Validating prerequisites...${NC}"
    
    # Check if libvirtd is running
    if ! systemctl is-active --quiet libvirtd; then
        echo -e "${RED}ERROR: libvirtd is not running${NC}"
        echo "Start it with: sudo systemctl start libvirtd"
        exit 1
    fi
    
    # Check if ISO exists
    if [ ! -f "$ISO_FILE" ]; then
        echo -e "${RED}ERROR: ISO file not found: $ISO_FILE${NC}"
        exit 1
    fi
    
    # Check if kickstart exists
    if [ ! -f "$KICKSTART_FILE" ]; then
        echo -e "${RED}ERROR: Kickstart file not found: $KICKSTART_FILE${NC}"
        exit 1
    fi
    
    # Check if VM already exists
    if virsh list --all | grep -q "$VM_NAME"; then
        echo -e "${RED}ERROR: VM '$VM_NAME' already exists${NC}"
        exit 1
    fi
    
    # Check storage pool
    if ! virsh pool-list | grep -q "$VM_NETWORK"; then
        echo -e "${YELLOW}WARNING: Network/pool '$VM_NETWORK' not found${NC}"
        echo "Available networks:"
        virsh net-list
        exit 1
    fi
    
    echo -e "${GREEN}[SUCCESS] All prerequisites validated${NC}"
}

# Create HTTP server for kickstart (if needed)
setup_kickstart_http_server() {
    echo -e "${YELLOW}Setting up kickstart delivery...${NC}"
    
    # Get absolute paths
    ISO_PATH="$(cd "$(dirname "$ISO_FILE")" && pwd)/$(basename "$ISO_FILE")"
    KICKSTART_PATH="$(cd "$(dirname "$KICKSTART_FILE")" && pwd)/$(basename "$KICKSTART_FILE")"
    
    # Create temporary directory for kickstart hosting
    KICKSTART_HTTP_DIR="/tmp/rhel-kickstart-$$"
    mkdir -p "$KICKSTART_HTTP_DIR"
    
    # Copy kickstart to HTTP directory
    cp "$KICKSTART_PATH" "$KICKSTART_HTTP_DIR/oem.cfg"
    
    # Start simple HTTP server in background
    cd "$KICKSTART_HTTP_DIR"
    python3 -m http.server 8888 > /dev/null 2>&1 &
    HTTP_SERVER_PID=$!
    cd - > /dev/null
    
    # Get local IP for HTTP delivery
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    KICKSTART_URL="http://$LOCAL_IP:8888/oem.cfg"
    
    echo -e "${GREEN}[SUCCESS] Kickstart server started (PID: $HTTP_SERVER_PID)${NC}"
    echo "  URL: $KICKSTART_URL"
    
    # Store for cleanup
    echo $HTTP_SERVER_PID > /tmp/rhel-ks-server-$$.pid
    echo "$KICKSTART_HTTP_DIR" > /tmp/rhel-ks-dir-$$.path
}

# Create the VM
create_vm() {
    echo -e "${YELLOW}Creating VM: $VM_NAME${NC}"
    
    # Get absolute ISO path
    ISO_PATH="$(cd "$(dirname "$ISO_FILE")" && pwd)/$(basename "$ISO_FILE")"
    
    # Get local IP for HTTP delivery
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    KICKSTART_URL="http://$LOCAL_IP:8888/oem.cfg"
    
    # Build network argument
    NETWORK_ARG="--network $VM_NETWORK"
    if [ -n "$MAC_ADDRESS" ]; then
        NETWORK_ARG="--network $VM_NETWORK,mac=$MAC_ADDRESS"
    fi
    if [ -n "$BRIDGE_DEVICE" ]; then
        NETWORK_ARG="--network bridge=$BRIDGE_DEVICE"
    fi
    
    # Build virt-install command
    VIRT_INSTALL_CMD="virt-install \
        --name=$VM_NAME \
        --memory=$VM_MEMORY \
        --vcpus=$VM_CPUS \
        --disk size=$VM_DISK \
        --cdrom=$ISO_PATH \
        $NETWORK_ARG \
        --graphics=vnc \
        --console=pty,target_type=serial \
        --extra-args=\"console=ttyS0 inst.ks=$KICKSTART_URL\" \
        --noautoconsole \
        --wait=-1"
    
    echo -e "${YELLOW}Running virt-install...${NC}"
    echo "$VIRT_INSTALL_CMD"
    echo ""
    
    eval "$VIRT_INSTALL_CMD" || {
        echo -e "${RED}ERROR: Failed to create VM${NC}"
        cleanup_http_server
        exit 1
    }
    
    echo -e "${GREEN}[SUCCESS] VM created successfully${NC}"
}

# Monitor VM installation
monitor_vm() {
    echo -e "${YELLOW}Monitoring VM installation...${NC}"
    echo "To access the VM console, run:"
    echo "  virsh console $VM_NAME"
    echo ""
    
    # Wait for VM to start
    sleep 5
    
    # Check VM state
    for i in {1..60}; do
        STATE=$(virsh domstate $VM_NAME 2>/dev/null || echo "not found")
        echo -ne "\r[$(printf "%3d" $i)/300] VM State: $STATE"
        
        if [ "$STATE" = "shut off" ]; then
            echo ""
            echo -e "${GREEN}[SUCCESS] VM installation completed${NC}"
            break
        fi
        
        sleep 5
    done
}

# Cleanup HTTP server
cleanup_http_server() {
    echo -e "${YELLOW}Cleaning up...${NC}"
    
    # Find and kill HTTP server
    if [ -f "/tmp/rhel-ks-server-$$.pid" ]; then
        PID=$(cat /tmp/rhel-ks-server-$$.pid)
        kill $PID 2>/dev/null || true
        rm -f /tmp/rhel-ks-server-$$.pid
    fi
    
    # Remove temporary directory
    if [ -f "/tmp/rhel-ks-dir-$$.path" ]; then
        DIR=$(cat /tmp/rhel-ks-dir-$$.path)
        rm -rf "$DIR"
        rm -f /tmp/rhel-ks-dir-$$.path
    fi
    
    echo -e "${GREEN}[SUCCESS] Cleanup completed${NC}"
}

# Verify VM
verify_vm() {
    echo -e "${YELLOW}Verifying VM...${NC}"
    
    # Check VM exists
    virsh dominfo "$VM_NAME" > /dev/null 2>&1 || {
        echo -e "${RED}ERROR: VM verification failed${NC}"
        return 1
    }
    
    echo -e "${GREEN}[SUCCESS] VM created successfully!${NC}"
    echo ""
    echo "VM Details:"
    echo "  Name: $VM_NAME"
    echo "  CPUs: $VM_CPUS"
    echo "  Memory: $VM_MEMORY MB"
    echo "  Disk: $VM_DISK GB"
    echo ""
    echo "Management commands:"
    echo "  Start:    virsh start $VM_NAME"
    echo "  Stop:     virsh shutdown $VM_NAME"
    echo "  Console:  virsh console $VM_NAME"
    echo "  Info:     virsh dominfo $VM_NAME"
    echo "  Delete:   virsh undefine $VM_NAME --remove-all-storage"
}

# Main execution
main() {
    echo -e "${GREEN}"
    echo ""
    echo "  Libvirt VM Creation from ISO & Kickstart  "
    echo ""
    echo -e "${NC}"
    
    echo "Configuration:"
    echo "  VM Name:        $VM_NAME"
    echo "  CPUs:           $VM_CPUS"
    echo "  Memory:         $VM_MEMORY MB"
    echo "  Disk:           $VM_DISK GB"
    echo "  Network:        $VM_NETWORK"
    echo "  ISO File:       $ISO_FILE"
    echo "  Kickstart File: $KICKSTART_FILE"
    echo ""
    
    # Validate
    validate_prerequisites
    echo ""
    
    # Setup kickstart delivery
    setup_kickstart_http_server
    echo ""
    
    # Create VM
    create_vm
    echo ""
    
    # Monitor
    monitor_vm
    echo ""
    
    # Verify
    verify_vm
    
    # Cleanup
    cleanup_http_server
}

# Run main
main
