# aap_controller

Configure Ansible Automation Platform controller instance with manifest, authentication, and certificates.

## Purpose

This role sets up an AAP controller instance for RHIS environments with:
- License manifest upload
- Authentication configuration
- Service certificate installation
- Manifest fetching from CDN

## Requirements

- AAP controller must be accessible and running
- Python ansible.controller collection installed
- Manifest zip file available

## Role Variables

### Required Variables
```yaml
aap_controller_host: "controller.example.com"
aap_controller_username: "admin"
aap_controller_password: "{{ aap_admin_password }}"
```

### Optional Variables
```yaml
aap_manifest_source_path: "/tmp/rhis_aap_manifest.zip"
aap_manifest_force: true
aap_controller_validate_certs: false
```

## Example Usage

```yaml
- hosts: localhost
  roles:
    - role: aap_controller
      vars:
        aap_controller_host: "aap-controller.prod.spg"
        aap_manifest_source_path: "/opt/manifests/aap.zip"
```

## Tags

- `rhis_controller_setup` - All controller setup tasks
- `rhis_controller_manifest` - Manifest-related tasks
- `rhis_controller_certificate` - Certificate configuration
- `rhis_controller_auth` - Authentication configuration

## Notes

- Credentials should be provided via environment variables or vault
- See `defaults/main.yml` for configuration options
- Tasks can be run individually using tags

## Migration Source

Originally from `contrib/upstreams/rhis-builder/hosts/controller/tasks/`
