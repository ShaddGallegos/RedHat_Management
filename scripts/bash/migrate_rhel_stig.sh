#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROLES_DIR="$ROOT_DIR/roles"
TARGET_ROLE="$ROLES_DIR/rhel_stig"

mkdir -p "$TARGET_ROLE/tasks"
mkdir -p "$TARGET_ROLE/defaults"

move_if_exists(){
  src="$1"
  dst="$2"
  if [ -f "$src" ]; then
    echo "Moving $src -> $dst"
    mv "$src" "$dst"
  else
    echo "Skipping missing $src"
  fi
}

move_if_exists "$ROLES_DIR/ansible-role-rhel8-cis/tasks/main.yml" "$TARGET_ROLE/tasks/rhel8_main.yml"
move_if_exists "$ROLES_DIR/ansible-role-rhel9-cis/tasks/main.yml" "$TARGET_ROLE/tasks/rhel9_main.yml"
move_if_exists "$ROLES_DIR/ansible-role-rhel8-stig/tasks/main.yml" "$TARGET_ROLE/tasks/rhel8_stig_main.yml"
move_if_exists "$ROLES_DIR/ansible-role-rhel9-stig/tasks/main.yml" "$TARGET_ROLE/tasks/rhel9_stig_main.yml"

# Also consider other RHEL-* roles that match pattern
for src in "$ROLES_DIR"/ansible-role-rhel*-cis "$ROLES_DIR"/ansible-role-rhel*-stig; do
  for d in $src; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    if [ -f "$d/tasks/main.yml" ]; then
      echo "Moving $d/tasks/main.yml -> $TARGET_ROLE/tasks/${name}_main.yml"
      mv "$d/tasks/main.yml" "$TARGET_ROLE/tasks/${name}_main.yml"
    fi
  done
done

cat > "$TARGET_ROLE/defaults/main.yml" <<'EOF'
---
# Default: detect RHEL major version at runtime, can be overridden
rhel_version: "{{ ansible_distribution_major_version | default('8') }}"
EOF

echo "Migration skeleton created at $TARGET_ROLE"
echo "Please inspect moved files and update playbooks to point at ansible-role-rhel-stig."
