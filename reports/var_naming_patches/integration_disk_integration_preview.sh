#!/usr/bin/env bash
# Preview script for role: integration_disk_integration
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

echo 'Role: integration_disk_integration'
echo 'Mappings:'
echo '  target_disk -> integration_disk_integration_target_disk'
echo '  vg_name -> integration_disk_integration_vg_name'
echo '  lv_name -> integration_disk_integration_lv_name'
echo '  lv_size -> integration_disk_integration_lv_size'
echo '  mount_point -> integration_disk_integration_mount_point'
echo '  fs_type -> integration_disk_integration_fs_type'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: target_disk -> integration_disk_integration_target_disk'
grep -R -l -w -e target_disk $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" target_disk integration_disk_integration_target_disk > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e target_disk $EXCLUDES .) || true
echo '---'
echo 'Mapping: vg_name -> integration_disk_integration_vg_name'
grep -R -l -w -e vg_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" vg_name integration_disk_integration_vg_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e vg_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: lv_name -> integration_disk_integration_lv_name'
grep -R -l -w -e lv_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" lv_name integration_disk_integration_lv_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e lv_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: lv_size -> integration_disk_integration_lv_size'
grep -R -l -w -e lv_size $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" lv_size integration_disk_integration_lv_size > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e lv_size $EXCLUDES .) || true
echo '---'
echo 'Mapping: mount_point -> integration_disk_integration_mount_point'
grep -R -l -w -e mount_point $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" mount_point integration_disk_integration_mount_point > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e mount_point $EXCLUDES .) || true
echo '---'
echo 'Mapping: fs_type -> integration_disk_integration_fs_type'
grep -R -l -w -e fs_type $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" fs_type integration_disk_integration_fs_type > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e fs_type $EXCLUDES .) || true
echo 'Preview complete.'
