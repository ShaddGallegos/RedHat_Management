# Updates and Patching (migrated)

This role is the landing zone for the former `updates-and-patching` project. It should orchestrate lifecycle steps for system patching:

- install: prerequisites (repos, tooling)
- configure: policies, maintenance windows, notifications
- test: pre/post validation and smoke checks
- backup: snapshots or data protection before patching
- restore: rollback/recover flows

Source reference: `/run/media/sgallego/SD_Card/GIT/updates-and-patching` contained playbooks like `site-updates-and-patching.yml`, roles such as `update-rhel`, `register_rhel`, `kpatch-rhel`, `check-vulner`, and reporting utilities.

Next steps to fully migrate:

1. Port the functional tasks from the original roles (e.g., `update-rhel/tasks/*`) into the appropriate phase files here, or include them as delegated roles.
2. Bring over needed defaults/vars/templates/handlers from the original repo.
3. Wire inventories and variables (group_vars/host_vars) from the original project into `inventory/` and vars files under this role as needed.
4. Replace placeholder debug tasks with real logic and ensure idempotent behavior.

Current migration status:

- Copied original `update-rhel` role into `roles/updates_and_patching/roles/update-rhel` and wired it into `tasks/configure.yml` via `import_role`.
- Placeholders remain for other source roles (e.g., register_rhel, kpatch-rhel, reporting). Port or include them next.

Inventory example: see `inventory/updates_and_patching_inventory.yml`.
