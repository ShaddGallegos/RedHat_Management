# LVM Auto-Extension on Nutanix with AAP & EDA

This project provides automated LVM extension for RHEL 8/9 systems on Nutanix using Ansible Automation Platform (AAP) with Event-Driven Ansible (EDA). It detects high disk usage, creates ServiceNow tickets, and automatically extends LVM volumes as needed.

## Overview

The automation handles the entire LVM extension workflow:

1. **Monitoring**: Detect high disk usage on monitored systems
2. **Event Processing**: Process alerts through EDA rulebook
3. **ServiceNow Integration**: Create and update tickets for tracking
4. **LVM Inspection**: Check if sufficient space exists
5. **Smart Extension**: Extend using existing space or create new disk
6. **Nutanix Integration**: Create new disks when needed
7. **Notification**: Alert appropriate teams about actions taken

## Key Components

- **EDA Rulebook**: Processes disk usage events and triggers appropriate workflows
- **Disk Monitoring**: Detects high disk usage conditions
- **ServiceNow Integration**: Creates, updates and closes tickets
- **LVM Roles**: Inspects and extends LVM volumes
- **Nutanix Integration**: Creates additional disks when needed

## Requirements

- Ansible Automation Platform 2.2+
- Event-Driven Ansible 1.0+
- RHEL 8/9 target systems
- Nutanix environment
- ServiceNow instance with appropriate permissions
- Required collections (see requirements.yml)

## Directory Structure

```
.
├── CHANGELOG.md # Version history
├── QUICKSTART.md # Quick start guide
├── README.md # This file
├── disk_integration_with_snow.yml # Disk integration playbook
├── disk_usage_monitor.yml # Disk usage monitoring
├── extend_lvm.yml # LVM extension playbook
├── extend_lvm_with_snow.yml # Extension with ServiceNow
├── inventory/ # Inventory files
│ ├── group_vars/ # Group variables
│ │ ├── all.yml # Common variables
│ │ └── nutanix_hosts.yml # Nutanix-specific variables
│ ├── hosts # Inventory file
│ └── hosts.example # Example inventory
├── non_lvm_alert.yml # Handles non-LVM filesystems
├── nutanix_disk_creation_with_snow.yml # Creates disks in Nutanix
├── playbooks/ # ServiceNow integration playbooks
│ ├── servicenow_close_ticket.yml
│ ├── servicenow_create_manual_ticket.yml
│ ├── servicenow_create_ticket.yml
│ └── servicenow_update_ticket.yml
├── requirements.yml # Required collections and roles
├── roles/ # Custom roles
│ ├── lvm_smart_extend/ # LVM extension role
│ ├── lvm_system_inspection/ # LVM inspection role
│ └── servicenow_ticket_management/ # ServiceNow integration role
├── rulebook.yml # EDA rulebook
├── test/ # Test files
│ ├── inventory # Test inventory
│ └── test_lvm_extension.yml # Test playbook
└── unsupported_os_alert.yml # Handles unsupported OS versions
```

## Setup Instructions

For detailed setup instructions, see the [QUICKSTART.md](QUICKSTART.md) guide.

### Quick Start

1. Install required collections and roles:
 ```bash
 ansible-galaxy collection install -r requirements.yml
 ansible-galaxy role install -r requirements.yml
 ```

2. Configure inventory:
 - Copy inventory/hosts.example to inventory/hosts
 - Add your systems to inventory/hosts
 - Update group_vars with appropriate settings

3. Configure ServiceNow credentials:
 ```bash
 export SNOW_USER=your_username
 export SNOW_PASS=your_password
 ```

4. Configure Nutanix credentials:
 ```bash
 export NUTANIX_USER=your_username
 export NUTANIX_PASS=your_password
 export NUTANIX_HOST=your_cluster_ip
 ```

5. Start EDA rulebook:
 ```bash
 ansible-rulebook -r rulebook.yml --inventory inventory/hosts
 ```

## Testing

For testing without affecting production systems:

1. Use the test inventory and playbook:
 ```bash
 ansible-playbook -i test/inventory test/test_lvm_extension.yml
 ```

2. To manually trigger the disk usage monitor:
 ```bash
 ansible-playbook -i inventory/hosts disk_usage_monitor.yml -e "threshold_percent=50"
 ```

## ServiceNow Integration

This automation integrates with ServiceNow for ticket management:

- Creates incidents for high disk usage alerts
- Updates tickets with progress information
- Closes tickets when resolution is complete
- Handles manual intervention tickets for unsupported scenarios

## License

MIT

## Author Information

Your Name - your.email@example.com
