# aap_deploy

Deploy Ansible Automation Platform using the AAP installer.

## Purpose

This role handles the complete AAP deployment workflow:
- Download AAP installer bundle
- Extract installer components
- Generate installer configuration
- Launch AAP installation

## Requirements

- Installer bundle available or downloadable
- Target controller hosts accessible via SSH
- SSH keys configured for deployment
- Sufficient disk space for installation

## Role Variables

### Required Variables
```yaml
controllers:
  - name: controller1
    fqdn: "controller1.example.com"
aap_installer_bundle_dir: "/opt/aap-installer"
```

### Optional Variables
```yaml
aap_installer_version: "2.6"
aap_content_source_path: "/opt/aap-content"
builder_key_file: "~/.ssh/id_rsa"
```

## Example Usage

```yaml
- hosts: localhost
  roles:
    - role: aap_deploy
      vars:
        aap_installer_bundle_dir: "/opt/aap-2.6"
        controllers:
          - name: controller1
            fqdn: "aap-controller.prod.spg"
```

## Tags

- `rhis_aap_deploy` - All deployment tasks
- `rhis_aap_download` - Download content
- `rhis_aap_extract` - Extract installer
- `rhis_aap_generate_config` - Generate configuration
- `rhis_aap_launch` - Launch installer

## Notes

- Requires SSH access to target controller hosts
- Installation takes 10-30 minutes depending on configuration
- See `defaults/main.yml` for all configuration options

## Migration Source

Originally from `contrib/upstreams/rhis-builder/hosts/controller/tasks/`
