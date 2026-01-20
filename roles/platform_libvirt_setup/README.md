# platform_libvirt_setup

This role prepares libvirt host networking and related configuration for platform deployments.

Usage (apply to your libvirt host inventory):

```yaml
- name: Configure libvirt host
  hosts: libvirt_host
  become: true
  roles:
    - role: platform_libvirt_setup
      vars:
        external_device: "eth1"
        external_type: "bridge"
        internal_device: "virbr0"
        internal_subnet: "192.168.122.0/24"
```

The variables are defined in `roles/platform_libvirt_setup/defaults/main.yml` and were merged from
`roles/ansible_dev_node_env_config/network_defaults.j2` so you can set them at group_vars or host_vars as needed.
