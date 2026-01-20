# Example RHIS Inventory

This directory contains example inventory and configuration skeletons compatible with the `rhis-builder-inventory` layout. Copy or adapt files from https://github.com/parmstro/rhis-builder-inventory as needed.

Files:

- `version.txt` — schema version of the example inventory.
- `inventory.ini` — sample Ansible inventory for local testing.
- `group_vars/example.yml` — group-level variables used by playbooks.
- `host_vars/example.yml` — host-level variables.
- `templates/` — sample platform_provisioning templates (placeholders).

Populate these with your real values or copy upstream files into this directory to enable `rhis-provisioner` and other builder flows.
