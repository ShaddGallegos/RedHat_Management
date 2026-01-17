# Satellite OS Configuration Role

## Description

The `satellite_os_configuration` role configures Satellite 6.18 with RHEL 9 and RHEL 10 operating systems, install media, kickstart repositories, and automatic synchronization jobs.

## Features

- **Operating Systems**: RHEL 9 and RHEL 10 OS definitions
- **Install Media**: BaseOS installation media for both RHEL versions
- **Kickstart Repository**: Dedicated repository for kickstart files with weekly sync
- **Sync Jobs**: Automated weekly synchronization of kickstart repository
- **Partition Tables**: Compliance-ready LVM-based partitioning
- **Bootdisk Management**: Configuration for bootable installation media

## Required Variables

```yaml
satellite_url: "https://satellite.example.com"
satellite_username: "admin"
satellite_password: "{{ vault_satellite_admin_pwd }}"
```

## Usage

```yaml
- role: satellite_os_configuration
  vars:
    create_operatingsystems: true
    create_install_media: true
    create_kickstart_repo: true
    configure_sync_job: true
```
