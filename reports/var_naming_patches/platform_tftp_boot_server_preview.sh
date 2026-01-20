#!/usr/bin/env bash
# Preview script for role: platform_tftp_boot_server
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

echo 'Role: platform_tftp_boot_server'
echo 'Mappings:'
echo '  tftp_server_ip -> platform_tftp_boot_server_tftp_server_ip'
echo '  tftp_enable -> platform_tftp_boot_server_tftp_enable'
echo '  tftp_enable_firewall -> platform_tftp_boot_server_tftp_enable_firewall'
echo '  tftp_root -> platform_tftp_boot_server_tftp_root'
echo '  tftp_iso_dir -> platform_tftp_boot_server_tftp_iso_dir'
echo '  project_root -> platform_tftp_boot_server_project_root'
echo '  dhcp_tftp_server -> platform_tftp_boot_server_dhcp_tftp_server'
echo '  dhcp_boot_file -> platform_tftp_boot_server_dhcp_boot_file'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: tftp_server_ip -> platform_tftp_boot_server_tftp_server_ip'
grep -R -l -w -e tftp_server_ip $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_server_ip platform_tftp_boot_server_tftp_server_ip > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_server_ip $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_enable -> platform_tftp_boot_server_tftp_enable'
grep -R -l -w -e tftp_enable $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_enable platform_tftp_boot_server_tftp_enable > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_enable $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_enable_firewall -> platform_tftp_boot_server_tftp_enable_firewall'
grep -R -l -w -e tftp_enable_firewall $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_enable_firewall platform_tftp_boot_server_tftp_enable_firewall > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_enable_firewall $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_root -> platform_tftp_boot_server_tftp_root'
grep -R -l -w -e tftp_root $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_root platform_tftp_boot_server_tftp_root > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_root $EXCLUDES .) || true
echo '---'
echo 'Mapping: tftp_iso_dir -> platform_tftp_boot_server_tftp_iso_dir'
grep -R -l -w -e tftp_iso_dir $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" tftp_iso_dir platform_tftp_boot_server_tftp_iso_dir > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e tftp_iso_dir $EXCLUDES .) || true
echo '---'
echo 'Mapping: project_root -> platform_tftp_boot_server_project_root'
grep -R -l -w -e project_root $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" project_root platform_tftp_boot_server_project_root > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e project_root $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_tftp_server -> platform_tftp_boot_server_dhcp_tftp_server'
grep -R -l -w -e dhcp_tftp_server $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_tftp_server platform_tftp_boot_server_dhcp_tftp_server > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_tftp_server $EXCLUDES .) || true
echo '---'
echo 'Mapping: dhcp_boot_file -> platform_tftp_boot_server_dhcp_boot_file'
grep -R -l -w -e dhcp_boot_file $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" dhcp_boot_file platform_tftp_boot_server_dhcp_boot_file > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e dhcp_boot_file $EXCLUDES .) || true
echo 'Preview complete.'
