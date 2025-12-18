#!/usr/bin/env bash
set -euo pipefail

# Simple helper to run prompts, prepare env/vault files, and optionally install collections.
# Usage: scripts/run_setup.sh [--skip-collections]

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SKIP_COLLECTIONS=false
if [[ "${1-}" == "--skip-collections" ]]; then
  SKIP_COLLECTIONS=true
fi

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[ERROR] Missing required command: $1" >&2
    exit 1
  }
}

require_cmd ansible-playbook

# 1) Run the prompts to gather Satellite/AAP/IdM/Insights vars
echo "[INFO] Running prompts (system_prompts.yml)…"
ansible-playbook system_prompts.yml

generated_env="${ROOT_DIR}/env.local.generated.yml"
if [[ ! -f "$generated_env" ]]; then
  echo "[ERROR] Expected env.local.generated.yml not found after prompts." >&2
  exit 1
fi

# 2) Seed env.yml if missing
if [[ ! -f "${ROOT_DIR}/env.yml" ]]; then
  echo "[INFO] Creating env.yml from env.local.generated.yml"
  cp "$generated_env" "${ROOT_DIR}/env.yml"
else
  echo "[INFO] env.yml already exists; leaving untouched."
fi

# 3) Seed vault.yml if missing
if [[ ! -f "${ROOT_DIR}/vault.yml" ]]; then
  if [[ -f "${ROOT_DIR}/vault.yml.example" ]]; then
    echo "[INFO] Creating vault.yml from vault.yml.example"
    cp "${ROOT_DIR}/vault.yml.example" "${ROOT_DIR}/vault.yml"
    echo "[REMINDER] Edit vault.yml and then encrypt it: ansible-vault encrypt vault.yml"
  else
    echo "[WARN] vault.yml.example not found; create vault.yml manually."
  fi
else
  echo "[INFO] vault.yml already exists; leaving untouched."
fi

# 4) Install collections (optional)
if [[ "$SKIP_COLLECTIONS" == false ]]; then
  if [[ -f "${ROOT_DIR}/requirements.yml" ]]; then
    echo "[INFO] Installing Galaxy collections from requirements.yml"
    ansible-galaxy collection install -r requirements.yml
  fi
  if [[ -f "${ROOT_DIR}/requirements_hub.yml" ]]; then
    echo "[INFO] Installing Automation Hub collections from requirements_hub.yml (requires token)"
    ansible-galaxy collection install -r requirements_hub.yml || true
  fi
else
  echo "[INFO] Skipping collection installs (flag set)."
fi

# 5) Final reminders
cat <<'EOF'
[INFO] Setup complete.
- Review and adjust env.yml (non-secret values, e.g., satellite DHCP ranges, AAP inventory hostnames, ansible.cfg template vars).
- Put secrets in vault.yml and run: ansible-vault encrypt vault.yml
- Run a syntax check before applying: ansible-playbook -i inventory/hosts -e @env.yml -e @vault.yml --syntax-check site-demo.yml
EOF
