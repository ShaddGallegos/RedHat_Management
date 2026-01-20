# Quick Start: Automated RHEL 10 VM Provisioning

Get up and running in 5 minutes!

## 1. Prepare Your Files

```bash
# Place RHEL 10 ISO in files directory
cp /path/to/rhel-10.iso files/

# Verify files exist
ls -lh files/rhel-10.iso files/oem.cfg
```

## 2. Verify Libvirt is Ready

```bash
# Check libvirtd is running
sudo systemctl start libvirtd

# Verify network exists
virsh net-list
# Should show: default  active  yes  yes
```

## 3. Create Your First VM

### **Option A: Bash Script (Fastest)**

```bash
# Create a simple test VM
./scripts/bash/create_libvirt_vm_from_iso.sh \
  --name my-first-vm \
  --cpus 2 \
  --memory 2048 \
  --disk 30
```

### **Option B: Python Tool**

```bash
# Create VM with config file
./scripts/python/platform_libvirt_vm_provisioner.py \
  --name my-first-vm \
  --cpus 2 \
  --memory 2048 \
  --disk 30 \
  --verbose
```

### **Option C: Ansible Playbook**

```bash
# Run the playbook
ansible-playbook playbooks/provision_rhel_vm_from_iso.yml \
  -e vm_name=my-first-vm \
  -e vm_cpus=2 \
  -e vm_memory=2048 \
  -e vm_disk=30
```

## 4. Monitor Installation

```bash
# Watch installation progress
virsh console my-first-vm
# Press Ctrl+] to exit

# In another terminal, check status
virsh domstate my-first-vm

# When done, get the IP
virsh domifaddr my-first-vm
```

## 5. Connect to Your VM

```bash
# SSH to the new VM
ssh root@<vm-ip-address>

# Verify RHEL 10 is installed
cat /etc/redhat-release
```

## Common Commands

```bash
# List all VMs
virsh list --all

# Start/stop VMs
virsh start my-first-vm
virsh shutdown my-first-vm

# Delete VM
virsh undefine my-first-vm --remove-all-storage

# View detailed VM info
virsh dominfo my-first-vm

# Check resource usage
virsh domstats my-first-vm
```

## Customize Kickstart

Edit `files/oem.cfg` to:
- Change root password
- Add packages
- Configure network
- Add custom users
- Run post-installation scripts

See [VM_PROVISIONING.md](VM_PROVISIONING.md) for detailed customization guide.

## Troubleshooting

**VM creation fails?**
```bash
# Check prerequisites
virsh net-list
virsh pool-list
ls -lh files/rhel-10.iso files/oem.cfg
```

**Can't access VM?**
```bash
# Get VM IP
virsh domifaddr my-first-vm

# Check VM is running
virsh list
```

**Installation hangs?**
```bash
# View installation log
virsh console my-first-vm
```

## Create Multiple VMs

```bash
# Create 3 test VMs
for i in {1..3}; do
  ./scripts/bash/create_libvirt_vm_from_iso.sh \
    --name test-vm-$i \
    --cpus 2 \
    --memory 2048 \
    --disk 30 &
done
wait
```

## Next Steps

1. **Customize Kickstart:** Edit `files/oem.cfg` for your specific needs
2. **Use Ansible:** Configure VMs with playbooks after creation
3. **Set Static IPs:** Modify kickstart for network configuration
4. **Integrate with AAP:** Add VMs to Ansible Automation Platform inventory
5. **Automate Creation:** Create VMs from scripts or CI/CD pipelines

---

For detailed documentation, see [VM_PROVISIONING.md](VM_PROVISIONING.md)
