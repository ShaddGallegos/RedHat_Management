roles/project_prompting — centralized prompting and local secrets
===============================================================

Purpose
-------
Centralize interactive prompting for deployment variables and provide a secure local storage location for secrets used by playbooks and roles.

What this role does
-------------------
- Presents a single, menu-driven prompt flow (via `system_prompts.yml`) to collect values for platform components, infra and integrations.
- Writes the collected values to a secure local file: `~/.ansible/conf/env.yml` (mode 0600).
- Appends sensitive values (passwords/tokens/secrets) into the same `~/.ansible/conf/env.yml` payload and keeps all prompted variable names unique.
- Enforces uniqueness checks for both variable names and non-empty answers.
- Encrypts `~/.ansible/conf/env.yml` with Ansible Vault using `~/.ansible/conf/.vaultpass.txt` (legacy fallback: `~/.ansible/conf/.vault_pass.txt`).
- Attempts to protect the `~/.ansible/conf` directory (permissions and optional immutable flag) using the provided scripts.

How to run
----------
Run the prompting playbook (interactive):

```bash
ansible-playbook system_prompts.yml
```

This will execute the `project_prompting` role and write `~/.ansible/conf/env.yml` when complete.

Secrets handling
----------------
- The canonical local secrets file is `~/.ansible/conf/env.yml`.
- Preferred vault password file is `~/.ansible/conf/.vaultpass.txt`.
- Legacy vault password file `~/.ansible/conf/.vault_pass.txt` is still accepted for compatibility.
- The role automatically encrypts `~/.ansible/conf/env.yml` with Ansible Vault when `project_prompting_auto_encrypt_env_file=true` (default).

Manual commands (if needed):

```bash
ansible-vault encrypt ~/.ansible/conf/env.yml --vault-password-file ~/.ansible/conf/.vaultpass.txt
```

To edit the encrypted file interactively:

```bash
ansible-vault edit ~/.ansible/conf/env.yml --vault-password-file ~/.ansible/conf/.vaultpass.txt
```

Protection utilities
--------------------
Scripts are included to assist admins:
- `scripts/protect_ansible_conf.sh` — sets strict permissions and writes a protector marker; attempts `chattr +i` where supported.
- `scripts/unprotect_ansible_conf.sh` — removes immutable flag and relaxes protection for admins when edits are required.

Pre-commit safety
-----------------
A git pre-commit hook template is provided at `.githooks/pre-commit-template` that can be used to block commits that add or modify `~/.ansible/conf` content into the repository.

Notes and limitations
---------------------
- The role uses `pause` for interactive prompts; `pause` does not support hidden input for secrets. For secret entry you have two options:
  1. Enter secrets into `~/.ansible/conf/env.yml` directly and then encrypt the file with `ansible-vault`.
  2. Rework the play to use `vars_prompt` (play-level) for hidden input — this requires a different invocation flow and is not the current default.

- The role writes `~/.ansible/conf/env.yml` with mode 0600. Administrators should encrypt the file with Vault for production use.

Canonical token variable
------------------------
This role consolidates Red Hat/Automation Hub tokens into a single canonical
variable: `project_prompting_console_redhat_token`.

- The `project_prompting_console_redhat_token` value will be written into
  `~/.ansible/conf/env.yml` by this role.
- Templates and playbooks in this repo have been updated to prefer
  `project_prompting_console_redhat_token` with safe fallbacks to legacy
  `console_redhat_token` or vault-backed variables.
- If you edit `~/.ansible/conf/env.yml` directly, you may keep the legacy
  `console_redhat_token` name for compatibility, but prefer the
  `project_prompting_console_redhat_token` name for new workflows.

When migrating other roles, prefer referencing the canonical variable. For
example in Jinja2 templates use:

```jinja
{{ project_prompting_console_redhat_token | default(console_redhat_token | default('')) }}
```

Developer guidance
------------------
- All variables defined by this role are prefixed with `project_prompting_` to satisfy repository linting rules.
- When updating other roles to read secrets, prefer reading from `lookup('file', lookup('env','HOME') + '/.ansible/conf/env.yml')` or include it via `vars_files` in playbooks.

Follow-up tasks
---------------
- Optional: migrate other roles to consume `~/.ansible/conf/env.yml` and remove play-level `vars_prompt` occurrences.
- Optional: implement a secure interactive secret entry mechanism (play-level `vars_prompt` for masked input) if desired.

Contact
-------
If you are the project admin and need help protecting or rotating secrets, run the protect/unprotect scripts and open an issue describing the change.
