#!/usr/bin/env bash
set -euo pipefail

# Install Ansible collections with optional Automation Hub support.
# If an Automation Hub token is not available, hub collections are skipped.

PROJ_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJ_ROOT"

echo "Installing collections (hub skipped if no token)..."

# Get token from env var first
TOKEN="${ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN:-}"

if [ -z "$TOKEN" ]; then
  # Try to read from ~/.ansible/conf/env.yml using Python YAML parser
  ENV_YML="$HOME/.ansible/conf/env.yml"
  if [ -f "$ENV_YML" ]; then
    TOKEN=$(python3 - <<'PY'
import yaml,sys,os
p=os.path.expanduser('~/.ansible/conf/env.yml')
try:
    d=yaml.safe_load(open(p)) or {}
except Exception:
    d={}
for k in ('rh_credentials_token','redhat_token','redhat_automation_hub_token','redhat_automation_hub_token_vault','redhat_automation_hub_token_vault'):
    if k in d and d[k]:
        print(d[k])
        sys.exit(0)
print('')
PY

  fi
fi

if [ -n "$TOKEN" ]; then
  export ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_TOKEN="$TOKEN"
  echo "Automation Hub token found — attempting hub collections install (allows pre-releases)..."
  ansible-galaxy collection install -r requirements_hub.yml -p ./collections --pre || {
    echo "Warning: Automation Hub collection install failed — continuing without hub collections." >&2
  }
else
  echo "Automation Hub token not found — skipping hub collections install."
fi

if [ -f requirements.yml ]; then
  echo "Installing public collections from requirements.yml..."
  ansible-galaxy collection install -r requirements.yml -p ./collections || {
    echo "Warning: public collection install failed — continuing." >&2
  }
else
  echo "No requirements.yml found — skipping public collection install."
fi

echo "Collection install step completed (errors were non-fatal)."

exit 0
