# Infrastructure - LibVirt Platform Guide

Complete guide for deploying RHIS on LibVirt/KVM.

## LibVirt Overview

LibVirt is an open-source virtualization management API and daemon providing:

- KVM/QEMU hypervisor ansible_dev_node_support
- Virtual networking and storage
- Virtual machine lifecycle management
- Migration and clustering
- Integration with OpenStack and other platforms

## Setup

### Install LibVirt

```bash
yum install -y libvirt libvirt-daemon-kvm qemu-kvm virt-manager virt-install
systemctl enable --now libvirtd
```

### Verify Installation

```bash
virsh list --all
virsh pool-list
virsh net-list
```

## Network Configuration

### Create Virtual Bridge

```bash
# Create bridge for VM connectivity
nmcli connection add type bridge ifname br0 con-name br0 \
  ipv4.method manual ipv4.addresses "192.168.1.1/24" \
  ipv4.gateway "192.168.1.1"

# Activate bridge
nmcli connection up br0
```

### Create Virtual Network

```bash
# Define network
virsh net-define <network.xml>
virsh net-start default
virsh net-autostart default
```

## Storage Configuration

### Create Storage Pool

```bash
# Define storage pool
virsh pool-define-as rhis dir --target /var/lib/libvirt/images

# Start pool
virsh pool-start rhis
virsh pool-autostart rhis
```

## VM Deployment

### Deploy VMs

```bash
# Using RHIS-installer
./scripts/setup/RHIS-installer.sh
# Select: libvirt platform

# VMs will be created automatically
virsh list --all
```

### VM Management

```bash
# Quick management using helper script
./scripts/libvirt/libvirt_vm_helper.sh list
./scripts/libvirt/libvirt_vm_helper.sh ip scenario_satellite
./scripts/libvirt/libvirt_vm_helper.sh console scenario_satellite
```

## Monitoring

### Monitor VMs

```bash
# Real-time monitoring
virt-top

# Check VM status
virsh domstats --running
```

### Performance Tuning

```bash
# Check CPU settings
virsh cputune <vm-name>

# Adjust CPU shares
virsh cputune <vm-name> --cpu-shares 1024
```

---

See [Infrastructure](../platform_infrastructure_core/) for other platform guides.
