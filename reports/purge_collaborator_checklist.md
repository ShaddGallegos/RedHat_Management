# Git History Purge — Collaborator Checklist

- Backup: Ensure an offline backup exists (`/home/sgallego/Downloads/RedHat_Management-backup.bundle`).
- Notification: Tell all contributors that history will be rewritten and they must re-clone or reset after the change.
- Credentials Rotation: Immediately rotate any secrets found in the report (`reports/secret_git_history_report.txt`) — e.g., change passwords, revoke API tokens.
- CI/CD: Update any CI/CD systems that reference commit SHAs or rely on existing history.
- Local instructions for contributors:
  1. Delete or move existing clones.
  2. Clone fresh: `git clone <repo-url>`
  Or reset an existing clone (advanced):
  ```bash
  git fetch --all
  git checkout main
  git reset --hard origin/main
  git clean -fdx
  ```
- Post-purge verification steps:
  - Confirm secret strings no longer appear in remote: run `git grep -F "bj8H7ndC7"` and `git grep -F "r3dh4t7!"` locally after recloning.
  - Run test suite and CI jobs to ensure no breakage.

# Suggested Communications
- Short message to send to team before push:
  "We will rewrite repository history to remove committed secrets. Please backup your work and avoid pushing while we perform this operation. After the rewrite, you must reclone or reset to the new origin."

- Follow-up message after push:
  "History rewrite complete. Please reclone the repository or follow the reset instructions provided. Rotate any credentials you use that may have been exposed earlier."
