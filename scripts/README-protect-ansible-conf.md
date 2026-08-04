Protecting local Ansible conf secrets
====================================

This small utility helps you protect your local Ansible secrets stored under `~/.ansible/conf`:

- `scripts/protect_ansible_conf.sh` — create `~/.ansible/conf` (if missing), create the files
  `.vault_pass.txt` and `env.yml` (if missing), set strict permissions, and attempt to set the
  immutable bit (using `chattr +i`) when available.

- `scripts/unprotect_ansible_conf.sh` — remove the immutable bit and delete the marker. By
  default only the user who ran `protect_ansible_conf.sh` may unprotect; use `--force` to override.

Usage
-----

Run:

```bash
./scripts/protect_ansible_conf.sh

# To unprotect (owning user):
./scripts/unprotect_ansible_conf.sh

# To force unprotect as a different user (use with caution):
./scripts/unprotect_ansible_conf.sh --force
```

Notes
-----
- `chattr` may require elevated privileges on some systems; the scripts will continue even if
  setting the immutable bit fails.
- These scripts do not change existing content of your files; they create them if missing and
  set permissions. They are meant to prevent accidental programmatic edits but are not a
  substitute for proper operational controls.
