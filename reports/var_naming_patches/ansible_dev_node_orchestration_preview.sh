#!/usr/bin/env bash
# Preview script for role: ansible_dev_node_orchestration
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

echo 'Role: ansible_dev_node_orchestration'
echo 'Mappings:'
echo '  orchestration_enabled -> ansible_dev_node_orchestration_orchestration_enabled'
echo '  orchestration_version -> ansible_dev_node_orchestration_orchestration_version'
echo '  orchestration_dry_run -> ansible_dev_node_orchestration_orchestration_dry_run'
echo '  orchestration_verbose -> ansible_dev_node_orchestration_orchestration_verbose'
echo '  orchestration_validate_dependencies -> ansible_dev_node_orchestration_orchestration_validate_dependencies'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: orchestration_enabled -> ansible_dev_node_orchestration_orchestration_enabled'
grep -R -l -w -e orchestration_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" orchestration_enabled ansible_dev_node_orchestration_orchestration_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e orchestration_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: orchestration_version -> ansible_dev_node_orchestration_orchestration_version'
grep -R -l -w -e orchestration_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" orchestration_version ansible_dev_node_orchestration_orchestration_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e orchestration_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: orchestration_dry_run -> ansible_dev_node_orchestration_orchestration_dry_run'
grep -R -l -w -e orchestration_dry_run $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" orchestration_dry_run ansible_dev_node_orchestration_orchestration_dry_run > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e orchestration_dry_run $EXCLUDES .) || true
echo '---'
echo 'Mapping: orchestration_verbose -> ansible_dev_node_orchestration_orchestration_verbose'
grep -R -l -w -e orchestration_verbose $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" orchestration_verbose ansible_dev_node_orchestration_orchestration_verbose > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e orchestration_verbose $EXCLUDES .) || true
echo '---'
echo 'Mapping: orchestration_validate_dependencies -> ansible_dev_node_orchestration_orchestration_validate_dependencies'
grep -R -l -w -e orchestration_validate_dependencies $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" orchestration_validate_dependencies ansible_dev_node_orchestration_orchestration_validate_dependencies > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e orchestration_validate_dependencies $EXCLUDES .) || true
echo 'Preview complete.'
