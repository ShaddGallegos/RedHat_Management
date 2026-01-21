#!/usr/bin/env bash
# Preview script for role: ansible_dev_node_inventory_generator
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

echo 'Role: ansible_dev_node_inventory_generator'
echo 'Mappings:'
echo '  inventory_generator_enabled -> ansible_dev_node_inventory_generator_inventory_generator_enabled'
echo '  inventory_generator_version -> ansible_dev_node_inventory_generator_inventory_generator_version'
echo '  inventory_generator_format -> ansible_dev_node_inventory_generator_inventory_generator_format'
echo '  inventory_generator_output -> ansible_dev_node_inventory_generator_inventory_generator_output'
echo '  inventory_generator_validate_syntax -> ansible_dev_node_inventory_generator_inventory_generator_validate_syntax'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: inventory_generator_enabled -> ansible_dev_node_inventory_generator_inventory_generator_enabled'
grep -R -l -w -e inventory_generator_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" inventory_generator_enabled ansible_dev_node_inventory_generator_inventory_generator_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e inventory_generator_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: inventory_generator_version -> ansible_dev_node_inventory_generator_inventory_generator_version'
grep -R -l -w -e inventory_generator_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" inventory_generator_version ansible_dev_node_inventory_generator_inventory_generator_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e inventory_generator_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: inventory_generator_format -> ansible_dev_node_inventory_generator_inventory_generator_format'
grep -R -l -w -e inventory_generator_format $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" inventory_generator_format ansible_dev_node_inventory_generator_inventory_generator_format > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e inventory_generator_format $EXCLUDES .) || true
echo '---'
echo 'Mapping: inventory_generator_output -> ansible_dev_node_inventory_generator_inventory_generator_output'
grep -R -l -w -e inventory_generator_output $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" inventory_generator_output ansible_dev_node_inventory_generator_inventory_generator_output > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e inventory_generator_output $EXCLUDES .) || true
echo '---'
echo 'Mapping: inventory_generator_validate_syntax -> ansible_dev_node_inventory_generator_inventory_generator_validate_syntax'
grep -R -l -w -e inventory_generator_validate_syntax $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" inventory_generator_validate_syntax ansible_dev_node_inventory_generator_inventory_generator_validate_syntax > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e inventory_generator_validate_syntax $EXCLUDES .) || true
echo 'Preview complete.'
