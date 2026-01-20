#!/usr/bin/env bash
set -euo pipefail

# Simple helper to run ansible_dev_node_prompts, prepare env/vault files, and optionally install collections.
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

# 1) Run the ansible_dev_node_prompts to gather Satellite/AAP/IdM/Insights vars
echo "[INFO] Running ansible_dev_node_prompts (system_prompts.yml)…"
ansible-playbook system_prompts.yml

generated_env="${ROOT_DIR}/env.local.generated.yml"
if [[ ! -f "$generated_env" ]]; then
  echo "[ERROR] Expected env.local.generated.yml not found after ansible_dev_node_prompts." >&2
  exit 1
fi

# 2) Offer to place generated env into a user-local config (never write user secrets into the repo)
USER_ENV_DIR="${HOME}/.ansible/conf"
USER_ENV_FILE="${USER_ENV_DIR}/env.yml"

echo "[INFO] A generated environment file is available at: ${generated_env}"
echo "For security, do NOT store personal credentials or hostnames in the project repository." \
     "You can move the generated file to your local config directory: ${USER_ENV_FILE}"

read -p "Copy generated env to ${USER_ENV_FILE}? (Y/n): " copy_choice
copy_choice="${copy_choice:-Y}"
if [[ "${copy_choice^^}" == "Y" ]]; then
  mkdir -p "${USER_ENV_DIR}"
  cp "${generated_env}" "${USER_ENV_FILE}"
  chmod 600 "${USER_ENV_FILE}"
  echo "[INFO] Generated env copied to ${USER_ENV_FILE}" 
  echo "[REMINDER] Encrypt or vault your secrets (ansible-vault encrypt ${USER_ENV_FILE})"
else
  echo "[INFO] Leaving generated env in place at ${generated_env}. Do not commit it to source control."
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
- Review and adjust env.yml (non-secret values, e.g., scenario_satellite DHCP ranges, AAP inventory hostnames, ansible.cfg template vars).
- Put secrets in vault.yml and run: ansible-vault encrypt vault.yml
- Run a syntax check before applying: ansible-playbook -i inventory/hosts -e @env.yml -e @vault.yml --syntax-check site-demo.yml
EOF
