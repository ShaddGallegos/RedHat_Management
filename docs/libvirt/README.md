# Libvirt Infrastructure Platform

## Synopsis

Libvirt is an open-source API, daemon, and management tool for virtualization. The RHIS project uses Libvirt as the primary platform_infrastructure_core platform for development, testing, and deployment of Red Hat management solutions. Libvirt provides:

- **KVM Virtualization** - High-performance kernel-based virtual machines
- **Virtual Networking** - Configurable network topologies and connectivity
- **Storage Management** - Local, networked, and cloud storage ansible_dev_node_support
- **Virtual Machine Lifecycle** - Create, manage, migrate, and backup VMs
- **Template Management** - Reusable VM templates and snapshots
- **Multi-Host Support** - Cluster and distributed virtualization

When deployed via RHIS, Libvirt provides the foundation for deploying AAP, Satellite, IdM, OpenShift, and other Red Hat solutions in a flexible lab or production environment.

---

## Quick Start

### Prerequisites
- Red Hat Enterprise Linux 9.x
- Intel VT-x or AMD-V capable CPU
- Minimum 32GB RAM (64GB recommended)
- 1TB+ storage (SSD recommended)
- KVM kernel modules enabled

### 1. Install Libvirt
```bash
# Install packages
yum install -y \
  libvirt \
  libvirt-daemon-kvm \
  libvirt-client \
  virt-manager \
  virt-install \
  qemu-kvm

# Start service
systemctl enable --now libvirtd

# Verify installation
virsh list --all
```

### 2. Configure Network
```bash
# Create virtual bridge
nmcli connection add type bridge ifname br0 con-name br0 \
  ipv4.method manual ipv4.addresses "192.168.1.1/24"

# Activate bridge
nmcli connection up br0

# Create NAT network
virsh net-define /dev/stdin << EOF
<network>
  <name>default</name>
  <bridge name="virbr0"/>
  <forward mode="nat"/>
  <ip address="192.168.122.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.122.100" end="192.168.122.254"/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-start default
virsh net-autostart default
```

### 3. Configure Storage
```bash
# Create storage pool
virsh pool-define-as rhis dir \
  --target /var/lib/libvirt/images/rhis

virsh pool-build rhis
virsh pool-start rhis
virsh pool-autostart rhis

# Verify pool
virsh pool-list
```

### 4. Deploy Infrastructure
```bash
# Run RHIS platform_infrastructure_core setup
ansible-playbook redhat_management-site.yml -t libvirt

# Verify deployment
virsh list
virsh net-list
virsh pool-list
```

---

## Installation

### Detailed Setup Process

#### Step 1: System Preparation
```bash
# Update system
yum update -y

# Verify CPU virtualization ansible_dev_node_support
grep -E "vmx|svm" /proc/cpuinfo

# Load KVM modules
cat >> /etc/modules-load.d/kvm.conf << EOF
kvm
kvm_intel
EOF

modprobe kvm
modprobe kvm_intel

# Verify module loading
lsmod | grep kvm
```

#### Step 2: Install Virtualization Stack
```bash
# Install base packages
yum groupinstall -y "Virtualization" "Virtualization Client"

# Install additional tools
yum install -y \
  libvirt-daemon-config-network \
  libvirt-daemon-config-nwfilter \
  virt-diagnose \
  virt-top \
  virt-viewer \
  guestfs-tools \
  libguestfs-tools

# Enable and start service
systemctl enable libvirtd
systemctl start libvirtd

# Verify installation
systemctl status libvirtd
virsh -c qemu:///system version
```

#### Step 3: Configure Host Networking
```bash
# Create primary bridge (for platform_infrastructure_core VMs)
cat > /etc/NetworkManager/dnsmasq.d/libvirt.conf << EOF
server=/example.com/192.168.1.1
EOF

# Restart networking
systemctl restart NetworkManager

# Test connectivity
virsh net-list
virsh net-define /usr/share/libvirt/networks/default.xml
virsh net-start default
virsh net-autostart default
```

#### Step 4: Configure Storage Pools
```bash
# Create storage directories
mkdir -p /var/lib/libvirt/images/{rhis,backups,templates}
chmod 755 /var/lib/libvirt/images/*

# Define storage pools
for pool in rhis backups templates; do
  virsh pool-define-as $pool dir --target /var/lib/libvirt/images/$pool
  virsh pool-build $pool
  virsh pool-start $pool
  virsh pool-autostart $pool
done

# Verify pools
virsh pool-list
```

#### Step 5: Run RHIS Infrastructure Setup
```bash
# Deploy platform_infrastructure_core via role
ansible-playbook -i inventory/hosts \
  roles/platform_infrastructure_prep/tasks/main.yml \
  --vault-password-file ~/.ansible/conf/vault.txt

# Or full playbook
ansible-playbook redhat_management-site.yml \
  -e "deployment_platform=libvirt" \
  --tags libvirt
```

#### Step 6: Verify Installation
```bash
# Check networks
virsh net-list
virsh net-info default

# Check storage pools
virsh pool-list
virsh pool-info rhis

# Check CPU and memory
virsh nodeinfo
virsh domblklist <domain-name>
```

---

## Integration with RHIS Project

### 1. VM Template Creation
```yaml
# playbooks/create_libvirt_templates.yml
---
- name: Create Libvirt VM Templates
  hosts: libvirt_host
  
  vars:
    templates:
      - name: "rhel-9-base"
        iso_url: "http://mirror.example.com/rhel-9/RHEL-9.iso"
        disk_size: "50G"
        memory: "2048"
        vcpus: 2
  
  tasks:
    - name: Download ISO
      get_url:
        url: "{{ item.iso_url }}"
        dest: "/var/lib/libvirt/images/{{ item.name }}.iso"
      loop: "{{ templates }}"
    
    - name: Create base VM
      shell: |
        virt-install \
          --name {{ item.name }} \
          --memory {{ item.memory }} \
          --vcpus {{ item.vcpus }} \
          --disk /var/lib/libvirt/images/{{ item.name }}.qcow2,size={{ item.disk_size }} \
          --cdrom /var/lib/libvirt/images/{{ item.name }}.iso \
          --network default \
          --console pty,target_type=serial \
          --noautoconsole
      loop: "{{ templates }}"
```

### 2. VM Deployment via Roles
```yaml
# playbooks/deploy_libvirt_vms.yml
---
- name: Deploy VMs for RHIS Infrastructure
  hosts: libvirt_host
  
  vars:
    vms:
      - name: "aap-controller"
        cpus: 4
        memory: 16384
        disk_size: 100
        network: "default"
        base_image: "rhel-9-base.qcow2"
      
      - name: "scenario_satellite"
        cpus: 4
        memory: 16384
        disk_size: 500
        network: "default"
        base_image: "rhel-9-base.qcow2"
      
      - name: "idm"
        cpus: 2
        memory: 8192
        disk_size: 50
        network: "default"
        base_image: "rhel-9-base.qcow2"
  
  tasks:
    - name: Create VMs from template
      shell: |
        qemu-img create -f qcow2 -b /var/lib/libvirt/images/{{ item.base_image }} \
          /var/lib/libvirt/images/{{ item.name }}.qcow2 {{ item.disk_size }}G
        
        virt-install \
          --name {{ item.name }} \
          --memory {{ item.memory }} \
          --vcpus {{ item.cpus }} \
          --disk /var/lib/libvirt/images/{{ item.name }}.qcow2 \
          --network {{ item.network }} \
          --import \
          --noautoconsole
      loop: "{{ vms }}"
```

### 3. Network Configuration
```yaml
# group_vars/libvirt.yml
libvirt_networks:
  - name: "management"
    bridge: "virbr0"
    mode: "nat"
    cidr: "192.168.122.0/24"
    dhcp_start: "192.168.122.100"
    dhcp_end: "192.168.122.254"
  
  - name: "prod"
    bridge: "virbr1"
    mode: "bridge"
    cidr: "192.168.1.0/24"

libvirt_storage_pools:
  - name: "rhis"
    type: "dir"
    path: "/var/lib/libvirt/images/rhis"
  
  - name: "backups"
    type: "dir"
    path: "/var/lib/libvirt/images/backups"
```

### 4. VM Lifecycle Management
```bash
# scripts/bash/manage_libvirt_vms.sh

#!/bin/bash

VIRSH="virsh"
ACTION=$1
VM_NAME=$2

case $ACTION in
  start)
    $VIRSH start $VM_NAME
    echo "Started VM: $VM_NAME"
    ;;
  
  stop)
    $VIRSH shutdown $VM_NAME
    echo "Stopped VM: $VM_NAME"
    ;;
  
  pause)
    $VIRSH suspend $VM_NAME
    echo "Paused VM: $VM_NAME"
    ;;
  
  snapshot)
    SNAP_NAME="$VM_NAME-$(date +%Y%m%d-%H%M%S)"
    $VIRSH snapshot-create-as $VM_NAME $SNAP_NAME
    echo "Created snapshot: $SNAP_NAME"
    ;;
  
  clone)
    NEW_NAME=$3
    qemu-img create -f qcow2 -b /var/lib/libvirt/images/$VM_NAME.qcow2 \
      /var/lib/libvirt/images/$NEW_NAME.qcow2
    virt-clone --original $VM_NAME --name $NEW_NAME --auto-clone
    echo "Cloned VM: $NEW_NAME"
    ;;
  
  backup)
    BACKUP_DIR="/var/lib/libvirt/images/backups"
    $VIRSH save $VM_NAME $BACKUP_DIR/$VM_NAME-$(date +%Y%m%d).xml
    echo "Backed up VM: $VM_NAME"
    ;;
esac
```

---

## Update & Upgrade

### Update Libvirt
```bash
# Check for updates
yum check-update libvirt*

# Update packages
yum update -y libvirt*

# Restart service (may interrupt running VMs)
systemctl restart libvirtd

# Verify connectivity
virsh nodeinfo
```

### Upgrade KVM Guest Tools
```bash
# Install guest tools on all VMs
ansible all -i inventory/hosts -m yum -a "name=qemu-guest-agent state=latest"

# Enable and start agent
ansible all -i inventory/hosts -m systemd -a "name=qemu-guest-agent enabled=yes state=started"
```

---

## Examples

### Example 1: Create VM with Cloud-Init
```yaml
---
- name: Create VM with Cloud-Init
  hosts: libvirt_host
  
  tasks:
    - name: Create cloud-init data
      template:
        src: cloud-init-data.yml.j2
        dest: /tmp/cloud-init-data.yml
      vars:
        hostname: "test-vm"
        users:
          - name: ansible
            sudo: "ALL=(ALL) NOPASSWD:ALL"
            ssh-authorized-keys:
              - "{{ ssh_public_key }}"
    
    - name: Create ISO for cloud-init
      shell: |
        genisoimage -output /var/lib/libvirt/images/cloud-init.iso \
          -volid cidata -joliet -rock \
          /tmp/meta-data /tmp/user-data
    
    - name: Create VM
      shell: |
        virt-install \
          --name cloud-init-vm \
          --memory 2048 \
          --vcpus 2 \
          --disk /var/lib/libvirt/images/cloud-init-vm.qcow2,size=50 \
          --cdrom /var/lib/libvirt/images/rhel-9.iso \
          --extra-args "inst.ks=file://ks.cfg" \
          --noautoconsole
```

### Example 2: VM Snapshots and Rollback
```bash
#!/bin/bash
# scripts/bash/vm_snapshots.sh

VM=$1
ACTION=$2
SNAPSHOT=$3

case $ACTION in
  create)
    echo "Creating snapshot: $SNAPSHOT"
    virsh snapshot-create-as $VM $SNAPSHOT \
      --description "Snapshot: $SNAPSHOT" \
      --atomic
    virsh snapshot-list $VM
    ;;
  
  revert)
    echo "Reverting to snapshot: $SNAPSHOT"
    virsh snapshot-revert $VM $SNAPSHOT --running
    ;;
  
  delete)
    echo "Deleting snapshot: $SNAPSHOT"
    virsh snapshot-delete $VM $SNAPSHOT --children --metadata
    ;;
  
  list)
    echo "Snapshots for VM: $VM"
    virsh snapshot-list $VM
    ;;
esac
```

### Example 3: VM Cloning for Testing
```yaml
---
- name: Clone VM for Testing
  hosts: libvirt_host
  
  vars:
    source_vm: "production-vm"
    clone_name: "test-vm-001"
    clone_count: 3
  
  tasks:
    - name: Clone VMs
      shell: |
        for i in $(seq 1 {{ clone_count }}); do
          virt-clone \
            --original {{ source_vm }} \
            --name {{ clone_name }}-$i \
            --auto-clone
        done
    
    - name: Start cloned VMs
      shell: |
        for i in $(seq 1 {{ clone_count }}); do
          virsh start {{ clone_name }}-$i
        done
```

### Example 4: Monitor VM Resources
```python
#!/usr/bin/env python3
# scripts/python/monitor_libvirt_vms.py

import libvirt
import sys

class LibvirtMonitor:
    def __init__(self):
        self.conn = libvirt.open('qemu:///system')
        if self.conn is None:
            print('Failed to connect to QEMU')
            sys.exit(1)
    
    def get_vm_stats(self):
        """Get stats for all VMs"""
        doms = self.conn.listAllDomains()
        stats = []
        
        for dom in doms:
            name = dom.name()
            state = dom.state()[0]
            info = dom.info()
            
            stats.append({
                'name': name,
                'state': self._state_name(state),
                'vcpus': info[3],
                'memory': info[1] // 1024,  # Convert to MB
                'max_memory': info[2] // 1024
            })
        
        return stats
    
    def _state_name(self, state):
        states = {
            0: 'NOSTATE',
            1: 'RUNNING',
            2: 'BLOCKED',
            3: 'PAUSED',
            4: 'SHUTDOWN',
            5: 'SHUTOFF',
            6: 'CRASHED'
        }
        return states.get(state, 'UNKNOWN')
    
    def print_stats(self):
        """Print VM statistics"""
        stats = self.get_vm_stats()
        print(f"{'VM Name':<30} {'State':<10} {'vCPUs':<8} {'Memory(MB)':<12}")
        print("-" * 60)
        
        for vm in stats:
            print(f"{vm['name']:<30} {vm['state']:<10} {vm['vcpus']:<8} {vm['memory']:<12}")

# Usage
monitor = LibvirtMonitor()
monitor.print_stats()
```

### Example 5: Automated Backup
```bash
#!/bin/bash
# scripts/bash/backup_libvirt_vms.sh

BACKUP_DIR="/var/lib/libvirt/images/backups"
RETENTION_DAYS=30

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup all VMs
for vm in $(virsh list --name); do
  echo "Backing up VM: $vm"
  
  # Create VM backup
  backup_file="$BACKUP_DIR/$vm-$(date +%Y%m%d_%H%M%S).xml"
  virsh dumpxml $vm > $backup_file
  
  # Create disk backup
  for disk in $(virsh domblklist $vm | grep /dev | awk '{print $2}'); do
    backup_disk="$BACKUP_DIR/$(basename $disk .qcow2)-$(date +%Y%m%d_%H%M%S).qcow2"
    cp $disk $backup_disk
  done
done

# Clean old backups
find $BACKUP_DIR -type f -mtime +$RETENTION_DAYS -delete
echo "Backup complete. Old backups cleaned."
```

---

## Troubleshooting

### Issue: VM Not Starting
```bash
# Check VM configuration
virsh edit <vm-name>

# View error logs
journalctl -xe

# Check disk permissions
ls -la /var/lib/libvirt/images/

# Verify disk integrity
qemu-img check /var/lib/libvirt/images/<vm>.qcow2
```

### Issue: Network Connectivity Problems
```bash
# List networks
virsh net-list

# Check network configuration
virsh net-dumpxml <network-name>

# Restart network
virsh net-destroy <network-name>
virsh net-start <network-name>

# Verify bridge
brctl show
```

### Issue: Storage Pool Issues
```bash
# List pools
virsh pool-list

# Refresh pool
virsh pool-refresh rhis

# Check pool path
virsh pool-info rhis

# Fix permissions
chmod 755 /var/lib/libvirt/images/*
chown libvirt:libvirt /var/lib/libvirt/images/*
```

---

## Additional Resources

- [Libvirt Project](https://libvirt.org/)
- [KVM Documentation](https://www.linux-kvm.org/)
- [Red Hat Virtualization Docs](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_basic_system_settings/using-virtualization_configuring-basic-system-settings)
- [RHIS Project Guide](../README.md)
- [Related: OpenShift on Libvirt](../scenario_openshift/README.md)

---

**Last Updated:** January 2026
**Supported Versions:** Libvirt 10.0+, KVM (latest RHEL 9)
**RHIS Primary Platform:** Libvirt with bridge networking
