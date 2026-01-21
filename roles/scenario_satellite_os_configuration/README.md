# Satellite OS Configuration Role

## Description

The `scenario_satellite_os_configuration` role configures Satellite 6.18 with RHEL 9 and RHEL 10 operating systems, install media, kickstart repositories, and automatic synchronization jobs.

## Features

- **Operating Systems**: RHEL 9 and RHEL 10 OS definitions
- **Install Media**: BaseOS installation media for both RHEL versions
- **Kickstart Repository**: Dedicated repository for kickstart files with weekly sync
- **Sync Jobs**: Automated weekly synchronization of kickstart repository
- **Partition Tables**: Compliance-ready LVM-based partitioning
- **Bootdisk Management**: Configuration for bootable installation media

## Required Variables

```yaml
scenario_satellite_os_configuration_satellite_url: "https://scenario_satellite.example.com"
scenario_satellite_os_configuration_satellite_username: "admin"
satellite_password: "{{ vault_satellite_admin_pwd }}"
```

## Usage

```yaml
- role: scenario_satellite_os_configuration
  vars:
    scenario_satellite_os_configuration_create_operatingsystems: true
    scenario_satellite_os_configuration_create_install_media: true
    scenario_satellite_os_configuration_create_kickstart_repo: true
    scenario_satellite_os_configuration_configure_sync_job: true
```
