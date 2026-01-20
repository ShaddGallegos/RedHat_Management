Consolidation proposal — AAP group (detailed mapping)

Purpose: merge fragmented AAP roles into a small, discoverable set under `roles/aap*`.

Canonical targets (proposal):
- `roles/aap` — core installation/configure tasks (install, configure, test, backup, restore)
- `roles/aap_controller` — controller-specific configuration and manifest handling
- `roles/aap_deploy` — deployment-related orchestration (playbooks/tasks previously in aap_deploy)
- `roles/aap_credentials` — credentials/secrets configuration
- `roles/aap_inventories` — inventories management
- `roles/aap_projects` — projects/repositories config
- `roles/aap_templates` — templates and job template configuration

File-level mapping (source -> target) — preview (no deletions applied):

1) `roles/aap/` -> `roles/aap/`
- Copy `roles/aap/tasks/*` -> `roles/aap/tasks/install.yml` (merge into single install task file)
- Copy `roles/aap/defaults/main.yml` -> merge into `roles/aap/defaults/main.yml` (normalize var names)
- Copy `roles/aap/meta/*` -> `roles/aap/meta/`

2) `roles/aap_controller/` -> `roles/aap_controller/`
- Copy `tasks/*` -> `roles/aap_controller/tasks/`
- Copy `defaults/`, `vars/`, `templates/`, `handlers/` -> corresponding `roles/aap_controller/` dirs

3) `roles/aap_deploy/` -> `roles/aap_deploy/`
- Copy `tasks/*` -> `roles/aap_deploy/tasks/`
- Copy `defaults/`, `vars/`, `templates/`, `handlers/` -> `roles/aap_deploy/`

4) `roles/aap_credentials/` -> `roles/aap_credentials/`
- Copy `tasks/*` -> `roles/aap_credentials/tasks/`
- Merge `defaults/main.yml` into `roles/aap/defaults/main.yml` under a `credentials` section or kept in `roles/aap_credentials/defaults` to limit blast radius.

5) `roles/aap_inventories/` -> `roles/aap_inventories/`
- Copy `tasks/*`, `defaults/*`, `tests/*` -> `roles/aap_inventories/`

6) `roles/aap_projects/` -> `roles/aap_projects/`
- Copy `tasks/*`, `defaults/*`, `tests/*` -> `roles/aap_projects/`

7) `roles/aap_templates/` -> `roles/aap_templates/`
- Copy `tasks/*`, `defaults/*`, `tests/*` -> `roles/aap_templates/`

8) `roles/aap_composite/` (composite) -> `roles/aap`
- The composite imports `install.yml, configure.yml, test.yml, backup.yml, restore.yml`.
- Move `roles/aap_composite/tasks/*` into `roles/aap/tasks/` with the same filenames (or keep `roles/aap_composite` as a compatibility wrapper that includes `roles/aap`).

References to update (examples):
- Update playbooks that include roles by name (search `git grep -n "aap_"` and `aap_composite`) and replace with new role names.
- Update docs (e.g., `docs/products/aap/README.md`) to reference canonical role names.

Variable reconciliation guidance:
- Where both `roles/aap_*` and `aap_composite` define defaults, create a merged `roles/aap/defaults/main.yml` and preserve legacy names as deprecation aliases, e.g.:

  aap_controller_manifest: "..."
  # legacy alias
  legacy_aap_controller_manifest: "{{ aap_controller_manifest }}"

Testing & safety:
- Create a per-group backup tarball (I have been creating backups before changes).
- I will prepare a preview patch that **copies** files into the new canonical locations and updates references. I will not delete source directories until you review.
- After preview is accepted we can either `git mv` (preserve history) or remove source folders.

Planned immediate actions (if you confirm):
1. Create `/consolidation_preview/aap/` staging copy with the proposed file layout. (no deletes)
2. Run `git grep` to list references and produce a replacements preview.
3. Run `ansible-playbook --syntax-check` on wrapper playbooks and `ansible-lint` for affected playbooks.
4. Present a concise diff for review.

Confirm and I will create the preview staging copy now (will not delete any original roles).