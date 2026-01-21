#!/usr/bin/env bash
# Preview script for role: scenario_ansible_cmdb_core
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

echo 'Role: scenario_ansible_cmdb_core'
echo 'Mappings:'
echo '  cmdb_enabled -> scenario_ansible_cmdb_core_cmdb_enabled'
echo '  cmdb_version -> scenario_ansible_cmdb_core_cmdb_version'
echo '  cmdb_timeout -> scenario_ansible_cmdb_core_cmdb_timeout'
echo '  cmdb_database -> scenario_ansible_cmdb_core_cmdb_database'
echo '  cmdb_update_frequency -> scenario_ansible_cmdb_core_cmdb_update_frequency'
echo '  cmdb_enable_tracking -> scenario_ansible_cmdb_core_cmdb_enable_tracking'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: cmdb_enabled -> scenario_ansible_cmdb_core_cmdb_enabled'
grep -R -l -w -e cmdb_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" cmdb_enabled scenario_ansible_cmdb_core_cmdb_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e cmdb_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: cmdb_version -> scenario_ansible_cmdb_core_cmdb_version'
grep -R -l -w -e cmdb_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" cmdb_version scenario_ansible_cmdb_core_cmdb_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e cmdb_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: cmdb_timeout -> scenario_ansible_cmdb_core_cmdb_timeout'
grep -R -l -w -e cmdb_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" cmdb_timeout scenario_ansible_cmdb_core_cmdb_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e cmdb_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: cmdb_database -> scenario_ansible_cmdb_core_cmdb_database'
grep -R -l -w -e cmdb_database $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" cmdb_database scenario_ansible_cmdb_core_cmdb_database > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e cmdb_database $EXCLUDES .) || true
echo '---'
echo 'Mapping: cmdb_update_frequency -> scenario_ansible_cmdb_core_cmdb_update_frequency'
grep -R -l -w -e cmdb_update_frequency $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" cmdb_update_frequency scenario_ansible_cmdb_core_cmdb_update_frequency > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e cmdb_update_frequency $EXCLUDES .) || true
echo '---'
echo 'Mapping: cmdb_enable_tracking -> scenario_ansible_cmdb_core_cmdb_enable_tracking'
grep -R -l -w -e cmdb_enable_tracking $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" cmdb_enable_tracking scenario_ansible_cmdb_core_cmdb_enable_tracking > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e cmdb_enable_tracking $EXCLUDES .) || true
echo 'Preview complete.'
