# ansible_cmdb_setup role

Installs ansible-cmdb and schedules a daily HTML report generation on the designated primary host of each hostgroup. By default the first host of every non-default inventory group is eligible; you can override with `ansible_cmdb_primary_host_override` or restrict with `ansible_cmdb_hostgroups`.

## Key variables

- `ansible_cmdb_install` (bool): enable/disable installation. Default `true`.
- `ansible_cmdb_hostgroups` (list): limit groups considered for primary selection. Empty uses all non-default groups, falling back to `all`.
- `ansible_cmdb_primary_host_override` (string): force a specific host to run ansible-cmdb.
- `ansible_cmdb_inventory_path` / `ansible_cmdb_inventory_file`: location of inventory to render.
- `ansible_cmdb_data_dir`: output directory for generated HTML. Default `/var/www/html/ansible-cmdb`.
- `ansible_cmdb_hostfacts`: optional extra facts argument to ansible-cmdb.
- `ansible_cmdb_cron_user` / `ansible_cmdb_cron_special_time`: cron owner and frequency (e.g., `daily`, `hourly`).
- `ansible_cmdb_expose_via_nginx`: when true, installs nginx site at `/ansible-cmdb` root.
- `ansible_cmdb_nginx_server_name`: server_name for nginx conf. Default `_`.

## Example play

```yaml
- hosts: all
  roles:
    - role: firewall_services
      vars:
        firewall_services_profiles_enabled: [satellite, ansible_cmdb]
    - role: ansible_cmdb_setup
      vars:
        ansible_cmdb_hostgroups: ["satellite"]
        ansible_cmdb_data_dir: /var/www/html/ansible-cmdb
        ansible_cmdb_expose_via_nginx: true
```
