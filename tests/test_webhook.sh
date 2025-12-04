#!/bin/bash
# Test webhook functionality

WEBHOOK_URL="http://localhost:5000/webhook"
TEST_HOST="test-server"

echo "Sending test webhook for high disk usage..."
curl -X POST -H "Content-Type: application/json" \
 -d '{
 "hostname": "'$TEST_HOST'",
 "disk_usage_percent": 95,
 "mount_point": "/data",
 "size_total": 107374182400,
 "size_available": 5368709120,
 "fstype": "ext4",
 "vg_name": "vg_data",
 "lv_name": "lv_data", 
 "device": "/dev/mapper/vg_data-lv_data",
 "is_lvm": true,
 "os_family": "RedHat",
 "os_version": "9"
 }' \
 $WEBHOOK_URL

echo -e "\nTest webhook sent!"
