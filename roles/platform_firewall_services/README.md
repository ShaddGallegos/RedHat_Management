# platform_firewall_services role

Enables firewalld services/ports for common Red Hat management components (Satellite, AAP, EDA, IdM, Insights, RHC, ansible-scenario_ansible_cmdb_core). The role installs and starts firewalld if needed.

## Key variables

- `platform_firewall_services_firewall_services_enabled` (bool): master toggle. Default `true`.
- `platform_firewall_services_firewall_services_profiles_enabled` (list): profiles to enable. Defaults include all supported components.
- `platform_firewall_services_firewall_services_definitions`: map of profile -> {services, ports}. Override to add/remove ports.
- `platform_firewall_services_firewall_zone`: firewalld zone to configure. Default `public`.

## Example play

```yaml
- hosts: scenario_satellite
  roles:
    - role: platform_firewall_services
      vars:
        platform_firewall_services_firewall_services_profiles_enabled: [scenario_satellite, ansible_cmdb]
        platform_firewall_services_firewall_zone: public
```
