# Static Files Directory

This directory is reserved for static files that need to be copied to the generated project.

## Purpose

The `files/` directory can contain:
- Static configuration files
- Scripts or utilities
- Certificates or keys (non-sensitive)
- Documentation assets
- Any other files that should be copied as-is

## Usage

Files placed here can be referenced in tasks using the `copy` module:

```yaml
- name: Copy static file to project
  ansible.builtin.copy:
    src: "{{ item }}"
    dest: "{{ aap_gcp_base_dir }}/{{ item }}"
  loop:
    - custom_script.sh
    - config_template.conf
```

## Current State

This directory is currently empty but maintained for future use.

## Security Note

**DO NOT** store sensitive information (passwords, API keys, service account JSON files) in this directory. Use Ansible Vault for secrets.
