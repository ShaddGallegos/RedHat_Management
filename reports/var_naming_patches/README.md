Preview-only var-naming patch bundles

Run the per-role preview scripts to see proposed variable renames and diffs.

Usage:

- To generate per-role preview scripts from the suggestions file (one-time):
  python3 reports/var_naming_patches/generate_var_naming_patches.py

- To preview changes for a role (example):
  bash reports/var_naming_patches/ansible_dev_node_common_tasks_preview.sh

Notes:
- Scripts do NOT modify repository files. They show matching lines and unified diffs.
- Grep excludes `.venv-ansible` and `.git` by default.
