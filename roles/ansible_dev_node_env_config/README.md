# ansible_dev_node_env_config

This role provides environment and network default templates used by dev/control nodes. It contains Jinja templates
for environment data and network variables (see `defaults.j2` and `network_defaults.j2`).

If you want to apply the same network defaults to a libvirt host, use the `platform_libvirt_setup` role which now
contains merged `network` defaults and a usage example.

Example (dev/control node usage):

```yaml
- name: Configure dev node environment
  hosts: localhost
  roles:
    - role: ansible_dev_node_env_config
      vars:
        host_list: ["libvirt_host"]
        group_list: ["libvirt"]
        external_device: "eth1"
        internal_device: "virbr0"
```
