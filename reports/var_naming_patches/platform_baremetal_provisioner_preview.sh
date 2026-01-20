#!/usr/bin/env bash
# Preview script for role: platform_baremetal_provisioner
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

echo 'Role: platform_baremetal_provisioner'
echo 'Mappings:'
echo '  baremetal_provisioner_enabled -> platform_baremetal_provisioner_baremetal_provisioner_enabled'
echo '  baremetal_provisioner_version -> platform_baremetal_provisioner_baremetal_provisioner_version'
echo '  baremetal_provisioner_timeout -> platform_baremetal_provisioner_baremetal_provisioner_timeout'
echo '  pxe_boot_enabled -> platform_baremetal_provisioner_pxe_boot_enabled'
echo '  dhcp_range_start -> platform_baremetal_provisioner_dhcp_range_start'
echo '  dhcp_range_end -> platform_baremetal_provisioner_dhcp_range_end'
echo '  tftp_root -> platform_baremetal_provisioner_tftp_root'
echo '  baremetal_provisioner_validate_hardware -> platform_baremetal_provisioner_baremetal_provisioner_validate_hardware'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: baremetal_provisioner_enabled -> platform_baremetal_provisioner_baremetal_provisioner_enabled'
grep -R -l -w -e baremetal_provisioner_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" baremetal_provisioner_enabled platform_baremetal_provisioner_baremetal_provisioner_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e baremetal_provisioner_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: baremetal_provisioner_version -> platform_baremetal_provisioner_baremetal_provisioner_version'
grep -R -l -w -e baremetal_provisioner_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" baremetal_provisioner_version platform_baremetal_provisioner_baremetal_provisioner_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e baremetal_provisioner_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: baremetal_provisioner_timeout -> platform_baremetal_provisioner_baremetal_provisioner_timeout'
grep -R -l -w -e baremetal_provisioner_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" baremetal_provisioner_timeout platform_baremetal_provisioner_baremetal_provisioner_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e baremetal_provisioner_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: pxe_boot_enabled -> platform_baremetal_provisioner_pxe_boot_enabled'
grep -R -l -w -e pxe_boot_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" pxe_boot_enabled platform_baremetal_provisioner_pxe_boot_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e pxe_boot_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_range_start -> platform_baremetal_provisioner_dhcp_range_start'
grep -R -l -w -e dhcp_range_start $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_range_start platform_baremetal_provisioner_dhcp_range_start > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_range_start $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_range_end -> platform_baremetal_provisioner_dhcp_range_end'
grep -R -l -w -e dhcp_range_end $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_range_end platform_baremetal_provisioner_dhcp_range_end > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_range_end $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_root -> platform_baremetal_provisioner_tftp_root'
grep -R -l -w -e tftp_root $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_root platform_baremetal_provisioner_tftp_root > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_root $EXCLUDES .) || true
echo '---'
echo 'Mapping: baremetal_provisioner_validate_hardware -> platform_baremetal_provisioner_baremetal_provisioner_validate_hardware'
grep -R -l -w -e baremetal_provisioner_validate_hardware $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" baremetal_provisioner_validate_hardware platform_baremetal_provisioner_baremetal_provisioner_validate_hardware > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e baremetal_provisioner_validate_hardware $EXCLUDES .) || true
echo 'Preview complete.'
