# LVM System Inspection Role

## Description

This Ansible role inspects LVM volume groups, logical volumes, and mount points on Linux systems.  
It generates usage reports, checks thresholds, and can send alerts via email or webhook.

## Requirements

- RHEL 8/9
- Ansible 2.9+ (recommended: 2.14+)
- LVM utilities (`lvs`, `vgs`) installed on target hosts
- Python 3.x on control and target nodes

## Role Variables

See [`defaults/main.yml`](defaults/main.yml) and [`vars/main.yml`](vars/main.yml) for all configurable options.

### Main Variables

- `lvm_inspect_mount_points`: List of mount points to inspect
- `lvm_inspect_vg_names`: List of volume groups to inspect
- `lvm_inspect_lv_names`: List of logical volumes to inspect
- `lvm_inspect_email`: Email address for alerts
- `lvm_inspect_enable_email_alert`: Enable/disable email alerts
- `lvm_inspect_enable_webhook`: Enable/disable webhook alerts
- `lvm_inspect_webhook_url`: Webhook URL for alerts
- `lvm_inspect_report_format`: "text" or "json"
- `lvm_inspect_critical_threshold_percent`: Critical usage threshold
- `lvm_inspect_warning_threshold_percent`: Warning usage threshold

See [`defaults/main.yml`](defaults/main.yml) for defaults.

### OS and Filesystem Support

- Supported RHEL versions: `lvm_supported_rhel_versions`
- Supported distributions: `lvm_supported_distributions`
- Supported filesystems: `lvm_supported_filesystems`
- Minimum kernel version: `lvm_min_supported_kernel`

See [`vars/main.yml`](vars/main.yml) for details.

## Example Playbook

```yaml
- hosts: servers
  roles:
    - role: lvm_system_inspection
      vars:
        lvm_inspect_email: "alerts@example.com"
        lvm_inspect_enable_email_alert: true
        lvm_inspect_enable_webhook: true
        lvm_inspect_webhook_url: "http://monitoring.example.com/webhook"
```

## Templates

Custom email templates can be found in [`templates/email_templates.yml`](templates/email_templates.yml).

## License

MIT

## Author

Your Name <your.email@example.com>
