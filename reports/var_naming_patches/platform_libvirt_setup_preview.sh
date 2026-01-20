#!/usr/bin/env bash
# Preview script for role: platform_libvirt_setup
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

echo 'Role: platform_libvirt_setup'
echo 'Mappings:'
echo '  external_device -> platform_libvirt_setup_external_device'
echo '  external_type -> platform_libvirt_setup_external_type'
echo '  internal_device -> platform_libvirt_setup_internal_device'
echo '  internal_subnet -> platform_libvirt_setup_internal_subnet'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: external_device -> platform_libvirt_setup_external_device'
grep -R -l -w -e external_device $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" external_device platform_libvirt_setup_external_device > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e external_device $EXCLUDES .) || true
echo '---'
echo 'Mapping: external_type -> platform_libvirt_setup_external_type'
grep -R -l -w -e external_type $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" external_type platform_libvirt_setup_external_type > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e external_type $EXCLUDES .) || true
echo '---'
echo 'Mapping: internal_device -> platform_libvirt_setup_internal_device'
grep -R -l -w -e internal_device $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" internal_device platform_libvirt_setup_internal_device > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e internal_device $EXCLUDES .) || true
echo '---'
echo 'Mapping: internal_subnet -> platform_libvirt_setup_internal_subnet'
grep -R -l -w -e internal_subnet $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" internal_subnet platform_libvirt_setup_internal_subnet > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e internal_subnet $EXCLUDES .) || true
echo 'Preview complete.'
