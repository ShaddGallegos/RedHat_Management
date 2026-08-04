#!/usr/bin/env bash
set -euo pipefail

# Unprotect previously protected Ansible conf files. By default only the user that protected
# them can unprotect; use --force to override.

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

ANSIBLE_CONF="$HOME/.ansible/conf"
VAULT_PASS="$ANSIBLE_CONF/.vault_pass.txt"
ENV_YML="$ANSIBLE_CONF/env.yml"
MARKER="$ANSIBLE_CONF/.protected_by_project"

if [[ ! -f "$MARKER" ]]; then
  echo "No marker file found at $MARKER; nothing to unprotect."
  exit 1
fi

PROTECTED_BY=$(awk -F= '/^protected_by=/ {print $2}' "$MARKER" || true)
CURRENT_USER=$(id -un)

if [[ "$FORCE" -ne 1 && "$PROTECTED_BY" != "$CURRENT_USER" ]]; then
  echo "Protected by '$PROTECTED_BY' — only that user may unprotect without --force."
  echo "Run with --force to override (be careful)."
  exit 2
fi

if command -v chattr >/dev/null 2>&1; then
  chattr -i "$VAULT_PASS" || true
  chattr -i "$ENV_YML" || true
fi

echo "Unprotected: $VAULT_PASS and $ENV_YML"
rm -f "$MARKER"
