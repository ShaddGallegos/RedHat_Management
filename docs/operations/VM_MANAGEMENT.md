# Operations - VM Management Guide

Manage virtual machines in your RHIS deployment.

## Using libvirt VM Helper

The `libvirt_vm_helper.sh` script provides quick VM operations:

```bash
./scripts/libvirt/libvirt_vm_helper.sh <command> [options]
```

### List All VMs

```bash
./scripts/libvirt/libvirt_vm_helper.sh list
```

### Get VM Information

```bash
./scripts/libvirt/libvirt_vm_helper.sh info rhel10-vm
```

### Connect to VM Console

```bash
./scripts/libvirt/libvirt_vm_helper.sh console rhel10-vm
# Press Ctrl+] to exit
```

### Get VM IP Address

```bash
./scripts/libvirt/libvirt_vm_helper.sh ip rhel10-vm
```

### Start/Stop VMs

```bash
# Start VM
./scripts/libvirt/libvirt_vm_helper.sh start rhel10-vm

# Stop VM
./scripts/libvirt/libvirt_vm_helper.sh stop rhel10-vm
```

### Delete VM

```bash
./scripts/libvirt/libvirt_vm_helper.sh delete rhel10-vm
```

### Clone VM

```bash
./scripts/libvirt/libvirt_vm_helper.sh clone source-vm new-vm
```

### Resize VM Disk

```bash
./scripts/libvirt/libvirt_vm_helper.sh resize rhel10-vm 100G
```

### Snapshots

```bash
# Create snapshot
./scripts/libvirt/libvirt_vm_helper.sh snapshot rhel10-vm

# Revert to snapshot
./scripts/libvirt/libvirt_vm_helper.sh revert rhel10-vm snapshot-name
```

## Common Tasks

### Monitor VM Performance

```bash
virt-top
```

### Migrate VM to Another Host

```bash
virsh migrate rhel10-vm qemu+ssh://host2/system
```

### Backup VM

```bash
virsh domblklist rhel10-vm
virsh snapshot-create-as rhel10-vm backup-$(date +%Y%m%d)
```

### VM Troubleshooting

```bash
# Check VM status
virsh list --all

# Get detailed VM info
virsh dumpxml rhel10-vm

# View logs
journalctl -u libvirtd -f
```

---

See [Operations](../operations/) for more procedures.
