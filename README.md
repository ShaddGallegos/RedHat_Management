# Red Hat Management Playbooks

This repository uses two collection requirement files:

- `requirements.yml`: Only public Galaxy content so installs succeed without Red Hat credentials.
- `requirements_hub.yml`: Red Hat Automation Hub content (Satellite, RHEL System Roles, AAP configuration). Requires an Automation Hub token.

## Installing collections

Public collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

Red Hat Automation Hub collections (requires subscription token):

```bash
export ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN=<your_token>
ansible-galaxy collection install -r requirements_hub.yml
```

If you do not need the Hub-only content, you can skip the second command.

## Roles added

- `roles/ansible_cmdb_setup`: installs and schedules ansible-cmdb on the primary host of each hostgroup (or a specified override). Optional nginx exposure is available when `ansible_cmdb_expose_via_nginx: true`.
- `roles/firewall_services`: enables firewalld ports/services for Satellite, AAP, EDA, IdM, Insights, RHC, and ansible-cmdb. Control with `firewall_services_profiles_enabled` and `firewall_zone`.
