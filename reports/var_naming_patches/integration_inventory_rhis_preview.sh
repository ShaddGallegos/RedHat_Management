#!/usr/bin/env bash
# Preview script for role: integration_inventory_rhis
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

echo 'Role: integration_inventory_rhis'
echo 'Mappings:'
echo '  rhis_templates_dir -> integration_inventory_rhis_rhis_templates_dir'
echo '  rhis_files_dir -> integration_inventory_rhis_rhis_files_dir'
echo '  rhis_provisioning_templates_dir -> integration_inventory_rhis_rhis_provisioning_templates_dir'
echo '  rhis_config_templates_dir -> integration_inventory_rhis_rhis_config_templates_dir'
echo '  rhis_inventory_templates_dir -> integration_inventory_rhis_rhis_inventory_templates_dir'
echo '  rhis_execution_env_templates_dir -> integration_inventory_rhis_rhis_execution_env_templates_dir'
echo '  rhis_openscan_files_dir -> integration_inventory_rhis_rhis_openscan_files_dir'
echo '  rhis_scripts_dir -> integration_inventory_rhis_rhis_scripts_dir'
echo '  rhis_example_inventory_dir -> integration_inventory_rhis_rhis_example_inventory_dir'
echo '  rhis_use_custom_tasks -> integration_inventory_rhis_rhis_use_custom_tasks'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: rhis_templates_dir -> integration_inventory_rhis_rhis_templates_dir'
grep -R -l -w -e rhis_templates_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_templates_dir integration_inventory_rhis_rhis_templates_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_templates_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhis_files_dir -> integration_inventory_rhis_rhis_files_dir'
grep -R -l -w -e rhis_files_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_files_dir integration_inventory_rhis_rhis_files_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_files_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhis_provisioning_templates_dir -> integration_inventory_rhis_rhis_provisioning_templates_dir'
grep -R -l -w -e rhis_provisioning_templates_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_provisioning_templates_dir integration_inventory_rhis_rhis_provisioning_templates_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_provisioning_templates_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhis_config_templates_dir -> integration_inventory_rhis_rhis_config_templates_dir'
grep -R -l -w -e rhis_config_templates_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_config_templates_dir integration_inventory_rhis_rhis_config_templates_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_config_templates_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhis_inventory_templates_dir -> integration_inventory_rhis_rhis_inventory_templates_dir'
grep -R -l -w -e rhis_inventory_templates_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_inventory_templates_dir integration_inventory_rhis_rhis_inventory_templates_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_inventory_templates_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhis_execution_env_templates_dir -> integration_inventory_rhis_rhis_execution_env_templates_dir'
grep -R -l -w -e rhis_execution_env_templates_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_execution_env_templates_dir integration_inventory_rhis_rhis_execution_env_templates_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_execution_env_templates_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhis_openscan_files_dir -> integration_inventory_rhis_rhis_openscan_files_dir'
grep -R -l -w -e rhis_openscan_files_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_openscan_files_dir integration_inventory_rhis_rhis_openscan_files_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_openscan_files_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhis_scripts_dir -> integration_inventory_rhis_rhis_scripts_dir'
grep -R -l -w -e rhis_scripts_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_scripts_dir integration_inventory_rhis_rhis_scripts_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_scripts_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhis_example_inventory_dir -> integration_inventory_rhis_rhis_example_inventory_dir'
grep -R -l -w -e rhis_example_inventory_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_example_inventory_dir integration_inventory_rhis_rhis_example_inventory_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_example_inventory_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: rhis_use_custom_tasks -> integration_inventory_rhis_rhis_use_custom_tasks'
grep -R -l -w -e rhis_use_custom_tasks $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" rhis_use_custom_tasks integration_inventory_rhis_rhis_use_custom_tasks > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e rhis_use_custom_tasks $EXCLUDES .) || true
echo 'Preview complete.'
