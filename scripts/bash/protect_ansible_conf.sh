#!/usr/bin/env bash
set -euo pipefail

# Protect ~/.ansible/conf/.vault_pass.txt and ~/.ansible/conf/env.yml by creating them
# and setting restrictive permissions and an immutable bit (chattr +i) when available.
# Records the protecting user in ~/.ansible/conf/.protected_by_project so only that user
# can unprotect without --force.

ANSIBLE_CONF="$HOME/.ansible/conf"
VAULT_PASS="$ANSIBLE_CONF/.vault_pass.txt"
ENV_YML="$ANSIBLE_CONF/env.yml"
MARKER="$ANSIBLE_CONF/.protected_by_project"

mkdir -p "$ANSIBLE_CONF"
touch "$VAULT_PASS" "$ENV_YML"
chmod 600 "$VAULT_PASS" "$ENV_YML"

# Record protector
echo "protected_by=$(id -un)" > "$MARKER"
chmod 600 "$MARKER"

if command -v chattr >/dev/null 2>&1; then
  # Try to set immutable; ignore failures (may require root on some systems)
  chattr +i "$VAULT_PASS" || true
  chattr +i "$ENV_YML" || true
fi

echo "Protected: $VAULT_PASS and $ENV_YML"
echo "Protector recorded in $MARKER"
