#!/usr/bin/env bash
# Preview script for role: integration_extend_disk_on_alert
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

echo 'Role: integration_extend_disk_on_alert'
echo 'Mappings:'
echo '  vg_name -> integration_extend_disk_on_alert_vg_name'
echo '  lv_name -> integration_extend_disk_on_alert_lv_name'
echo '  disk_img_path -> integration_extend_disk_on_alert_disk_img_path'
echo '  disk_device -> integration_extend_disk_on_alert_disk_device'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: vg_name -> integration_extend_disk_on_alert_vg_name'
grep -R -l -w -e vg_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" vg_name integration_extend_disk_on_alert_vg_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e vg_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: lv_name -> integration_extend_disk_on_alert_lv_name'
grep -R -l -w -e lv_name $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" lv_name integration_extend_disk_on_alert_lv_name > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e lv_name $EXCLUDES .) || true
echo '---'
echo 'Mapping: disk_img_path -> integration_extend_disk_on_alert_disk_img_path'
grep -R -l -w -e disk_img_path $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" disk_img_path integration_extend_disk_on_alert_disk_img_path > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e disk_img_path $EXCLUDES .) || true
echo '---'
echo 'Mapping: disk_device -> integration_extend_disk_on_alert_disk_device'
grep -R -l -w -e disk_device $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" disk_device integration_extend_disk_on_alert_disk_device > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e disk_device $EXCLUDES .) || true
echo 'Preview complete.'
