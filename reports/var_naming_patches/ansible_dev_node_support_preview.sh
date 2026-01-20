#!/usr/bin/env bash
# Preview script for role: ansible_dev_node_support
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

echo 'Role: ansible_dev_node_support'
echo 'Mappings:'
echo '  support_enabled -> ansible_dev_node_support_support_enabled'
echo '  support_version -> ansible_dev_node_support_support_version'
echo '  run_preflight_checks -> ansible_dev_node_support_run_preflight_checks'
echo '  run_tests -> ansible_dev_node_support_run_tests'
echo '  backup_and_restore -> ansible_dev_node_support_backup_and_restore'
echo '  configure_cmdb -> ansible_dev_node_support_configure_cmdb'
echo '  backup_destination -> ansible_dev_node_support_backup_destination'
echo '  backup_retention_days -> ansible_dev_node_support_backup_retention_days'
echo '  support_validate_deployment -> ansible_dev_node_support_support_validate_deployment'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: support_enabled -> ansible_dev_node_support_support_enabled'
grep -R -l -w -e support_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" support_enabled ansible_dev_node_support_support_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e support_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: support_version -> ansible_dev_node_support_support_version'
grep -R -l -w -e support_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" support_version ansible_dev_node_support_support_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e support_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: run_preflight_checks -> ansible_dev_node_support_run_preflight_checks'
grep -R -l -w -e run_preflight_checks $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" run_preflight_checks ansible_dev_node_support_run_preflight_checks > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e run_preflight_checks $EXCLUDES .) || true
echo '---'
echo 'Mapping: run_tests -> ansible_dev_node_support_run_tests'
grep -R -l -w -e run_tests $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" run_tests ansible_dev_node_support_run_tests > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e run_tests $EXCLUDES .) || true
echo '---'
echo 'Mapping: backup_and_restore -> ansible_dev_node_support_backup_and_restore'
grep -R -l -w -e backup_and_restore $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" backup_and_restore ansible_dev_node_support_backup_and_restore > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e backup_and_restore $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_cmdb -> ansible_dev_node_support_configure_cmdb'
grep -R -l -w -e configure_cmdb $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_cmdb ansible_dev_node_support_configure_cmdb > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_cmdb $EXCLUDES .) || true
echo '---'
echo 'Mapping: backup_destination -> ansible_dev_node_support_backup_destination'
grep -R -l -w -e backup_destination $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" backup_destination ansible_dev_node_support_backup_destination > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e backup_destination $EXCLUDES .) || true
echo '---'
echo 'Mapping: backup_retention_days -> ansible_dev_node_support_backup_retention_days'
grep -R -l -w -e backup_retention_days $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" backup_retention_days ansible_dev_node_support_backup_retention_days > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e backup_retention_days $EXCLUDES .) || true
echo '---'
echo 'Mapping: support_validate_deployment -> ansible_dev_node_support_support_validate_deployment'
grep -R -l -w -e support_validate_deployment $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" support_validate_deployment ansible_dev_node_support_support_validate_deployment > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e support_validate_deployment $EXCLUDES .) || true
echo 'Preview complete.'
