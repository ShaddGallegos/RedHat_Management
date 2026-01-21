#!/usr/bin/env bash
# Preview script for role: ansible_dev_node_product_lifecycle
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

echo 'Role: ansible_dev_node_product_lifecycle'
echo 'Mappings:'
echo '  product_lifecycle_enabled -> ansible_dev_node_product_lifecycle_product_lifecycle_enabled'
echo '  product_lifecycle_version -> ansible_dev_node_product_lifecycle_product_lifecycle_version'
echo '  product_lifecycle_timeout -> ansible_dev_node_product_lifecycle_product_lifecycle_timeout'
echo '  manage_product_updates -> ansible_dev_node_product_lifecycle_manage_product_updates'
echo '  manage_product_upgrades -> ansible_dev_node_product_lifecycle_manage_product_upgrades'
echo '  enable_rollback -> ansible_dev_node_product_lifecycle_enable_rollback'
echo '  product_lifecycle_validate_compatibility -> ansible_dev_node_product_lifecycle_product_lifecycle_validate_compatibility'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: product_lifecycle_enabled -> ansible_dev_node_product_lifecycle_product_lifecycle_enabled'
grep -R -l -w -e product_lifecycle_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" product_lifecycle_enabled ansible_dev_node_product_lifecycle_product_lifecycle_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e product_lifecycle_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: product_lifecycle_version -> ansible_dev_node_product_lifecycle_product_lifecycle_version'
grep -R -l -w -e product_lifecycle_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" product_lifecycle_version ansible_dev_node_product_lifecycle_product_lifecycle_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e product_lifecycle_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: product_lifecycle_timeout -> ansible_dev_node_product_lifecycle_product_lifecycle_timeout'
grep -R -l -w -e product_lifecycle_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" product_lifecycle_timeout ansible_dev_node_product_lifecycle_product_lifecycle_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e product_lifecycle_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: manage_product_updates -> ansible_dev_node_product_lifecycle_manage_product_updates'
grep -R -l -w -e manage_product_updates $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" manage_product_updates ansible_dev_node_product_lifecycle_manage_product_updates > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e manage_product_updates $EXCLUDES .) || true
echo '---'
echo 'Mapping: manage_product_upgrades -> ansible_dev_node_product_lifecycle_manage_product_upgrades'
grep -R -l -w -e manage_product_upgrades $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" manage_product_upgrades ansible_dev_node_product_lifecycle_manage_product_upgrades > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e manage_product_upgrades $EXCLUDES .) || true
echo '---'
echo 'Mapping: enable_rollback -> ansible_dev_node_product_lifecycle_enable_rollback'
grep -R -l -w -e enable_rollback $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" enable_rollback ansible_dev_node_product_lifecycle_enable_rollback > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e enable_rollback $EXCLUDES .) || true
echo '---'
echo 'Mapping: product_lifecycle_validate_compatibility -> ansible_dev_node_product_lifecycle_product_lifecycle_validate_compatibility'
grep -R -l -w -e product_lifecycle_validate_compatibility $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" product_lifecycle_validate_compatibility ansible_dev_node_product_lifecycle_product_lifecycle_validate_compatibility > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e product_lifecycle_validate_compatibility $EXCLUDES .) || true
echo 'Preview complete.'
