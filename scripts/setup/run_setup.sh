#!/usr/bin/env bash
set -euo pipefail


# Simple helper to run prompts, prepare env/vault files, and optionally install collections.
# Usage: scripts/run_setup.sh [--skip-collections] [--test] [--help]

# Print help and exit

TEST_MODE=false
SKIP_COLLECTIONS=false

for arg in "$@"; do
  case $arg in
    --help)
      cat <<EOF
Usage: run_setup.sh [--skip-collections] [--test] [--help]

  --skip-collections   Skip installing Ansible collections after prompts
  --test               Run non-interactively using ~/.ansible/conf/test-env.yml
  --help               Show this help message and exit

This script runs the standardized provisioning prompts (system_prompts.yml),
generates and vaults your environment file, and installs required collections.
EOF
      exit 0
      ;;
    --skip-collections)
      SKIP_COLLECTIONS=true
      ;;
    --test)
      TEST_MODE=true
      ;;
  esac
done

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

# Ensure SSH public key exists for user before any Ansible playbook runs
if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo "[INFO] SSH public key not found at $HOME/.ssh/id_rsa.pub. Generating new SSH key..."
  ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
  echo "[INFO] SSH key generated at $HOME/.ssh/id_rsa.pub."
fi

generated_env="${ROOT_DIR}/env.local.generated.yml"
generated_env="${ROOT_DIR}/env.local.generated.yml"


# 1) Run the standardized prompt suite to gather all provisioning variables
if [[ "$TEST_MODE" == true ]]; then
  echo "[INFO] Running in test mode: using ~/.ansible/conf/test-env.yml and skipping prompts."
  ansible-playbook system_prompts.yml --extra-vars "@${HOME}/.ansible/conf/test-env.yml"
else
  echo "[INFO] Running standardized provisioning prompts (system_prompts.yml)…"
  ansible-playbook system_prompts.yml
fi

generated_env="${ROOT_DIR}/env.local.generated.yml"
if [[ ! -f "$generated_env" ]]; then
  echo "[ERROR] Expected env.local.generated.yml not found after prompts." >&2
  exit 1
fi

# 2) Move and vault env file to ~/.ansible/conf/ with timestamp
PROJECT_NAME=$(awk '/^project_name:/ {print $2}' "$generated_env" | tr -cd '[:alnum:]_-')
DATE_TIME=$(date +%Y%m%d-%H%M%S)
ansible_conf_dir="$HOME/.ansible/conf"
mkdir -p "$ansible_conf_dir"
VAULTED_ENV_FILE="$ansible_conf_dir/${PROJECT_NAME}-${DATE_TIME}-env.yml"
mv "$generated_env" "$VAULTED_ENV_FILE"
echo "[INFO] Moved $generated_env to $VAULTED_ENV_FILE"
echo "[INFO] Encrypting $VAULTED_ENV_FILE with ansible-vault. You will be prompted for a password."
ansible-vault encrypt "$VAULTED_ENV_FILE"
echo "[INFO] Your vaulted env file is: $VAULTED_ENV_FILE"

# 4) Remove any env.yml in project root to avoid secrets in repo
if [[ -f "${ROOT_DIR}/env.yml" ]]; then
  echo "[INFO] Removing ${ROOT_DIR}/env.yml to avoid secrets in repo."
  rm -f "${ROOT_DIR}/env.yml"
fi


# Remove any env.yml or vault.yml in project root to avoid secrets in repo
if [[ -f "${ROOT_DIR}/env.yml" ]]; then
  echo "[INFO] Removing ${ROOT_DIR}/env.yml to avoid secrets in repo."
  rm -f "${ROOT_DIR}/env.yml"
fi
if [[ -f "${ROOT_DIR}/vault.yml" ]]; then
  echo "[INFO] Removing ${ROOT_DIR}/vault.yml to avoid secrets in repo."
  rm -f "${ROOT_DIR}/vault.yml"
fi

# 4) Install collections (optional)
if [[ "$SKIP_COLLECTIONS" == false ]]; then
  if [[ -f "${ROOT_DIR}/requirements.yml" ]]; then
    echo "[INFO] Installing Galaxy collections from requirements.yml (with --force)"
    ansible-galaxy collection install -r requirements.yml --force
  fi
  if [[ -f "${ROOT_DIR}/requirements_hub.yml" ]]; then
    echo "[INFO] Installing Automation Hub collections from requirements_hub.yml (with --force, requires token)"
    if ! ansible-galaxy collection install -r requirements_hub.yml --force; then
      echo "[WARN] Automation Hub collection install failed. Attempting to install local redhat-satellite collection from files/."
      local_collection_tar="${ROOT_DIR}/files/redhat-satellite-5.7.0.tar.gz"
      if [[ -f "$local_collection_tar" ]]; then
        ansible-galaxy collection install "$local_collection_tar" --force
      else
        echo "[ERROR] Local collection tarball not found: $local_collection_tar" >&2
        exit 1
      fi
    fi
  fi
else
  echo "[INFO] Skipping collection installs (flag set)."
fi


# 5) Report missing/uninstalled collections
echo "[INFO] Checking for missing or uninstalled collections from requirements..."
missing_collections=()
check_requirements_collections() {
  local req_file="$1"
  local collection_list=$(awk '/^- name:/ {print $3}' "$req_file")
  for coll in $collection_list; do
    if ! ansible-galaxy collection list | grep -q "^$coll "; then
      missing_collections+=("$coll")
    fi
  done
}
if [[ -f "${ROOT_DIR}/requirements.yml" ]]; then
  check_requirements_collections "${ROOT_DIR}/requirements.yml"
fi
if [[ -f "${ROOT_DIR}/requirements_hub.yml" ]]; then
  check_requirements_collections "${ROOT_DIR}/requirements_hub.yml"
fi
if [[ ${#missing_collections[@]} -eq 0 ]]; then
  echo "[INFO] All collections from requirements are installed."
else
  echo "[WARN] The following collections from requirements are NOT installed or failed to install:"
  for coll in "${missing_collections[@]}"; do
    echo "  - $coll"
  done
fi

# 6) Final reminders
cat <<EOF
[INFO] Setup complete.
- Your vaulted env file is: $VAULTED_ENV_FILE
- Reference it in your playbook runs, e.g.:
  ansible-playbook -i inventory/hosts -e @"$VAULTED_ENV_FILE" --ask-vault-pass --syntax-check site-demo.yml
EOF
