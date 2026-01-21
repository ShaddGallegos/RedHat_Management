Secrets lookup policy

Sensitive values (emails, passwords) should not be stored in `group_vars/all.yml`.
This repo now looks up sensitive values from the local file `~/.ansible/conf/env.yml`.

Expected format (YAML):

```yaml
# example keys
aap_password: "<secret>"
redhat_cdn_username: "user@example.com"
satellite_initial_admin_email: "admin@example.com"
```

The lookup is performed at runtime using the Ansible `file` lookup and `from_yaml`:

- `__ansible_env_file` is set to `$HOME/.ansible/conf/env.yml`
- `__ansible_env` contains the parsed YAML mapping
- Consumers use `{{ __ansible_env.<key> | default('<fallback>') }}`

If you need assistance creating `~/.ansible/conf/env.yml`, ask the maintainer.
