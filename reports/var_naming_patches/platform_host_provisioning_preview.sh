#!/usr/bin/env bash
# Preview script for role: platform_host_provisioning
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

echo 'Role: platform_host_provisioning'
echo 'Mappings:'
echo '  provisioning_hosts -> platform_host_provisioning_provisioning_hosts'
echo '  satellite_host -> platform_host_provisioning_satellite_host'
echo '  satellite_username -> platform_host_provisioning_satellite_username'
echo '  satellite_password -> platform_host_provisioning_satellite_password'
echo '  host_organization -> platform_host_provisioning_host_organization'
echo '  host_build_sync -> platform_host_provisioning_host_build_sync'
echo '  host_wait_timeout -> platform_host_provisioning_host_wait_timeout'
echo '  host_wait_sleep -> platform_host_provisioning_host_wait_sleep'
echo '  host_wait_port -> platform_host_provisioning_host_wait_port'
echo '  default_inventory_groups -> platform_host_provisioning_default_inventory_groups'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: provisioning_hosts -> platform_host_provisioning_provisioning_hosts'
grep -R -l -w -e provisioning_hosts $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" provisioning_hosts platform_host_provisioning_provisioning_hosts > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e provisioning_hosts $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_host -> platform_host_provisioning_satellite_host'
grep -R -l -w -e satellite_host $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_host platform_host_provisioning_satellite_host > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_host $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_username -> platform_host_provisioning_satellite_username'
grep -R -l -w -e satellite_username $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_username platform_host_provisioning_satellite_username > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_username $EXCLUDES .) || true
echo '---'
echo 'Mapping: satellite_password -> platform_host_provisioning_satellite_password'
grep -R -l -w -e satellite_password $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" satellite_password platform_host_provisioning_satellite_password > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e satellite_password $EXCLUDES .) || true
echo '---'
echo 'Mapping: host_organization -> platform_host_provisioning_host_organization'
grep -R -l -w -e host_organization $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" host_organization platform_host_provisioning_host_organization > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e host_organization $EXCLUDES .) || true
echo '---'
echo 'Mapping: host_build_sync -> platform_host_provisioning_host_build_sync'
grep -R -l -w -e host_build_sync $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" host_build_sync platform_host_provisioning_host_build_sync > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e host_build_sync $EXCLUDES .) || true
echo '---'
echo 'Mapping: host_wait_timeout -> platform_host_provisioning_host_wait_timeout'
grep -R -l -w -e host_wait_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" host_wait_timeout platform_host_provisioning_host_wait_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e host_wait_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: host_wait_sleep -> platform_host_provisioning_host_wait_sleep'
grep -R -l -w -e host_wait_sleep $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" host_wait_sleep platform_host_provisioning_host_wait_sleep > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e host_wait_sleep $EXCLUDES .) || true
echo '---'
echo 'Mapping: host_wait_port -> platform_host_provisioning_host_wait_port'
grep -R -l -w -e host_wait_port $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" host_wait_port platform_host_provisioning_host_wait_port > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e host_wait_port $EXCLUDES .) || true
echo '---'
echo 'Mapping: default_inventory_groups -> platform_host_provisioning_default_inventory_groups'
grep -R -l -w -e default_inventory_groups $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" default_inventory_groups platform_host_provisioning_default_inventory_groups > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e default_inventory_groups $EXCLUDES .) || true
echo 'Preview complete.'
