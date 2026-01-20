#!/usr/bin/env bash
# Preview script for role: ansible_dev_node_deployment_setup
set -euo pipefail

EXCLUDES="--exclude-dir=.venv-ansible --exclude-dir=.git --exclude-dir=.ansible"

TMPDIR=$(mktemp -d)
trap "rm -rf "$TMPDIR"" EXIT

cat > "$TMPDIR/replace.py" <<'PY'
import re,sys
from pathlib import Path

p=Path(sys.argv[1])
old=sys.argv[2]
new=sys.argv[3]
try:
    txt=p.read_text(encoding='utf-8',errors='ignore')
except Exception:
    txt=p.read_bytes().decode('utf-8','ignore')
pat=re.compile(r'\b' + re.escape(old) + r'\b')
print(pat.sub(new, txt), end='')
PY

echo 'Role: ansible_dev_node_deployment_setup'
echo 'Mappings:'
echo '  deployment_setup_enabled -> ansible_dev_node_deployment_setup_deployment_setup_enabled'
echo '  deployment_setup_version -> ansible_dev_node_deployment_setup_deployment_setup_version'
echo '  deployment_setup_directories -> ansible_dev_node_deployment_setup_deployment_setup_directories'
echo '  deployment_setup_validate_environment -> ansible_dev_node_deployment_setup_deployment_setup_validate_environment'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: deployment_setup_enabled -> ansible_dev_node_deployment_setup_deployment_setup_enabled'
grep -R -l -w -e deployment_setup_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" deployment_setup_enabled ansible_dev_node_deployment_setup_deployment_setup_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e deployment_setup_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: deployment_setup_version -> ansible_dev_node_deployment_setup_deployment_setup_version'
grep -R -l -w -e deployment_setup_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" deployment_setup_version ansible_dev_node_deployment_setup_deployment_setup_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e deployment_setup_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: deployment_setup_directories -> ansible_dev_node_deployment_setup_deployment_setup_directories'
grep -R -l -w -e deployment_setup_directories $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" deployment_setup_directories ansible_dev_node_deployment_setup_deployment_setup_directories > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e deployment_setup_directories $EXCLUDES .) || true
echo '---'
echo 'Mapping: deployment_setup_validate_environment -> ansible_dev_node_deployment_setup_deployment_setup_validate_environment'
grep -R -l -w -e deployment_setup_validate_environment $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" deployment_setup_validate_environment ansible_dev_node_deployment_setup_deployment_setup_validate_environment > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e deployment_setup_validate_environment $EXCLUDES .) || true
echo 'Preview complete.'
