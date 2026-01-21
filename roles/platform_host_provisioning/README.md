# platform_host_provisioning

Provision platform_infrastructure_core hosts from Satellite for AAP deployment.

## Purpose

This role handles host platform_provisioning workflow:
- Check if hosts exist in Satellite
- Create new hosts in Satellite
- Create hosts from predefined hostgroups
- Add provisioned hosts to Ansible inventory

## Requirements

- Satellite server accessible
- Hostgroups defined in Satellite
- Compute resources configured in Satellite
- Network access to provision hosts

## Role Variables

### Required Variables
```yaml
platform_host_provisioning_provisioning_hosts:
  - fqdn: "controller1.example.com"
    organization: "example"
    hostgroup: "baseRHEL8/Controller"
    compute_resource: "VMware_Lab"
    compute_profile: "SOE_Large"
    inventory_groups: ["controllers"]
```

### Optional Variables
```yaml
platform_host_provisioning_satellite_host: "scenario_satellite.example.com"
platform_host_provisioning_host_wait_timeout: 7200
platform_host_provisioning_host_wait_sleep: 60
```

## Example Usage

```yaml
- hosts: localhost
  roles:
    - role: platform_host_provisioning
      vars:
        platform_host_provisioning_provisioning_hosts:
          - fqdn: "controller1.prod.spg"
            hostgroup: "baseRHEL8/Controller"
            compute_resource: "VMware_Lab"
            inventory_groups: ["controllers", "aap"]
```

## Tags

- `rhis_host_provision` - All platform_provisioning tasks
- `rhis_host_check` - Check host existence
- `rhis_host_create` - Create new hosts
- `rhis_host_from_hostgroup` - Create from hostgroups
- `rhis_host_inventory` - Add to inventory

## Notes

- Requires Satellite connectivity and credentials
- Hosts will wait up to 2 hours for availability
- See `defaults/main.yml` for all configuration options

## Migration Source

Originally from `contrib/upstreams/rhis-builder/hosts/common/tasks/`
