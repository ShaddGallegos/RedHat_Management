# Satellite Mail Setup and Stack Bootstrap

This role bootstraps a POC stack on a single RHEL9 VM (libvirt) with Satellite, an SMTP service on Satellite, IdM (placeholder), and AAP (placeholder). It also generates a master variables file and an installer inventory on the controller.

## What it does

- Generates master vars file (`master_vars.yml` by default) for Satellite, AAP, and Insights.
- Generates an installer inventory (`installer_inventory.yml` by default) with optional targets (scenario_satellite, aap, scenario_openshift).
- Provisions a Satellite VM on the libvirt host (default `kaso.prod.spg` / `10.168.0.1`).
- Performs basic pre-work (admin/root keys, base packages).
- Stubs for Satellite install/config, IdM server, and AAP setup.
- Configures a local Postfix SMTP service on Satellite for notifications.

Secrets and ansible_dev_node_prompts:

- Secrets (passwords, relay creds) are not defaulted; provide via vars_prompt or a vaulted file at `~/.ansible/conf/env.yml` (referenced by `satellite_mail_vault_file`).
- Required secrets: `scenario_satellite_mail_setup_satellite_admin_password`, `scenario_satellite_mail_setup_aap_admin_password`, `scenario_satellite_mail_setup_insights_password`.

## Key vars (defaults/main.yml)

- `scenario_satellite_mail_setup_satellite_mail_targets`: [scenario_satellite, aap, scenario_openshift]
- `scenario_satellite_mail_setup_libvirt_host`: kaso.prod.spg (10.168.0.1), `satellite_vm_*` sizing, keys, network.
- `scenario_satellite_mail_setup_satellite_fqdn`, org/location, admin creds, mail relay info.
- Network ansible_dev_node_prompts (overrideable in `env.yml`): `satellite_domain`, `satellite_primary_interface`, optional `satellite_fqdn_ip`, `satellite_gateway`, `satellite_nameserver`, `satellite_dhcp_range_start`/`satellite_dhcp_range_end`, `satellite_pxeserver`.
- `scenario_satellite_mail_setup_aap_admin_password`, Insights credentials placeholders.

## Usage (example)

```yaml
- hosts: scenario_satellite
  roles:
    - role: scenario_satellite_mail_setup
      vars:
        scenario_satellite_mail_setup_satellite_mail_targets: ['scenario_satellite','aap']
        scenario_satellite_mail_setup_satellite_fqdn: scenario_satellite.poc.example.com
        scenario_satellite_mail_setup_satellite_mail_relay: smtp.example.com:587
        scenario_satellite_mail_setup_satellite_mail_relay_credentials: "[smtp.example.com]:587 user:pass"
```

Outputs:

- `master_vars.yml` (controller) with the assembled variables.
- `installer_inventory.yml` (controller) reflecting selected targets.

Next steps to harden:

- Replace placeholders with real Satellite installer invocation, IdM configuration, and AAP install.
- Point libvirt disk/pool/image to actual RHEL9 qcow2 or cloud-init source.
- Add TLS/auth details for Postfix relay as required.
