#!/usr/bin/env bash
# Preview script for role: scenario_ansible_cmdb_setup
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

echo 'Role: scenario_ansible_cmdb_setup'
echo 'Mappings:'
echo '  ansible_cmdb_setup_enabled -> scenario_ansible_cmdb_setup_ansible_cmdb_setup_enabled'
echo '  ansible_cmdb_setup_version -> scenario_ansible_cmdb_setup_ansible_cmdb_setup_version'
echo '  ansible_cmdb_output_format -> scenario_ansible_cmdb_setup_ansible_cmdb_output_format'
echo '  ansible_cmdb_output_directory -> scenario_ansible_cmdb_setup_ansible_cmdb_output_directory'
echo '  ansible_cmdb_setup_generate_docs -> scenario_ansible_cmdb_setup_ansible_cmdb_setup_generate_docs'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: ansible_cmdb_setup_enabled -> scenario_ansible_cmdb_setup_ansible_cmdb_setup_enabled'
grep -R -l -w -e ansible_cmdb_setup_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" ansible_cmdb_setup_enabled scenario_ansible_cmdb_setup_ansible_cmdb_setup_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e ansible_cmdb_setup_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: ansible_cmdb_setup_version -> scenario_ansible_cmdb_setup_ansible_cmdb_setup_version'
grep -R -l -w -e ansible_cmdb_setup_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" ansible_cmdb_setup_version scenario_ansible_cmdb_setup_ansible_cmdb_setup_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e ansible_cmdb_setup_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: ansible_cmdb_output_format -> scenario_ansible_cmdb_setup_ansible_cmdb_output_format'
grep -R -l -w -e ansible_cmdb_output_format $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" ansible_cmdb_output_format scenario_ansible_cmdb_setup_ansible_cmdb_output_format > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e ansible_cmdb_output_format $EXCLUDES .) || true
echo '---'
echo 'Mapping: ansible_cmdb_output_directory -> scenario_ansible_cmdb_setup_ansible_cmdb_output_directory'
grep -R -l -w -e ansible_cmdb_output_directory $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" ansible_cmdb_output_directory scenario_ansible_cmdb_setup_ansible_cmdb_output_directory > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e ansible_cmdb_output_directory $EXCLUDES .) || true
echo '---'
echo 'Mapping: ansible_cmdb_setup_generate_docs -> scenario_ansible_cmdb_setup_ansible_cmdb_setup_generate_docs'
grep -R -l -w -e ansible_cmdb_setup_generate_docs $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" ansible_cmdb_setup_generate_docs scenario_ansible_cmdb_setup_ansible_cmdb_setup_generate_docs > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e ansible_cmdb_setup_generate_docs $EXCLUDES .) || true
echo 'Preview complete.'
