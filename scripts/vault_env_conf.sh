#!/usr/bin/env bash
set -euo pipefail

# Helper to create files/env.conf and vault it into ~/.ansible/conf/env.conf
# It ansible_dev_node_prompts for GitHub user/repo/PAT and then encrypts interactively with ansible-vault.

TARGET_DIR="$HOME/.ansible/conf"
TARGET_FILE="$TARGET_DIR/env.conf"
TMP_FILE="/tmp/env.conf.$$"

echo "This will prompt for GitHub credentials and then run 'ansible-vault encrypt' interactively."
read -p "GitHub username: " GH_USER
read -p "GitHub repo (name): " GH_REPO
read -s -p "GitHub Personal Access Token (PAT): " GH_PAT
echo

cat > "$TMP_FILE" <<EOF
[github]
user = ${GH_USER}
repo = ${GH_REPO}
pat = ${GH_PAT}
EOF

mkdir -p "$TARGET_DIR"

echo "Encrypting and writing to ${TARGET_FILE} (you will be prompted for the vault password)..."
ansible-vault encrypt "$TMP_FILE" --output "$TARGET_FILE" --ask-vault-pass

shred -u "$TMP_FILE" || rm -f "$TMP_FILE"

echo "Vaulted to ${TARGET_FILE}. Keep your vault password safe."
