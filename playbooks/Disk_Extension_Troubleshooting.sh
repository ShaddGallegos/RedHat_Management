#!/bin/bash

echo "=== Disk Extension Troubleshooting ==="

# 1. Check if the disk image exists
DISK_IMG="/var/lib/libvirt/images/extra_disk.img"
if [ -f "$DISK_IMG" ]; then
    echo "[OK] Disk image exists: $DISK_IMG"
else
    echo "[ERROR] Disk image not found: $DISK_IMG"
fi

# 2. Check if the disk device exists
DISK_DEV="/dev/vdb"
if [ -b "$DISK_DEV" ]; then
    echo "[OK] Disk device exists: $DISK_DEV"
else
    echo "[ERROR] Disk device not found: $DISK_DEV"
    echo "Try running 'lsblk' or 'fdisk -l' to see available devices."
fi

# 3. Check PV status
echo "Checking Physical Volume status..."
pvdisplay "$DISK_DEV" 2>/dev/null || echo "[ERROR] PV not found on $DISK_DEV"

# 4. Check VG status
VG="vg_data"
echo "Checking Volume Group status..."
vgdisplay "$VG" 2>/dev/null || echo "[ERROR] Volume Group $VG not found"

# 5. Check LV status
LV="lv_data"
echo "Checking Logical Volume status..."
lvdisplay "/dev/$VG/$LV" 2>/dev/null || echo "[ERROR] Logical Volume /dev/$VG/$LV not found"

# 6. Check filesystem size and health
echo "Checking filesystem size and health..."
if mount | grep "/dev/$VG/$LV" > /dev/null; then
    df -h "/dev/$VG/$LV"
    tune2fs -l "/dev/$VG/$LV" | grep -E "Block count|Block size|Filesystem state"
else
    echo "[WARNING] /dev/$VG/$LV is not mounted. Skipping filesystem checks."
fi

# 7. Show recent logs for errors
echo "Showing recent system logs for disk and LVM errors..."
dmesg | tail -20
journalctl -xe | grep -i lvm | tail -20

echo "=== Troubleshooting Complete ==="