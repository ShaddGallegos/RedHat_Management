#!/usr/bin/env bash
# Preview script for role: platform_firewall_services
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

echo 'Role: platform_firewall_services'
echo 'Mappings:'
echo '  firewall_services_enabled -> platform_firewall_services_firewall_services_enabled'
echo '  firewall_services_profiles_enabled -> platform_firewall_services_firewall_services_profiles_enabled'
echo '  firewall_services_definitions -> platform_firewall_services_firewall_services_definitions'
echo '  firewall_zone -> platform_firewall_services_firewall_zone'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: firewall_services_enabled -> platform_firewall_services_firewall_services_enabled'
grep -R -l -w -e firewall_services_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" firewall_services_enabled platform_firewall_services_firewall_services_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e firewall_services_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: firewall_services_profiles_enabled -> platform_firewall_services_firewall_services_profiles_enabled'
grep -R -l -w -e firewall_services_profiles_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" firewall_services_profiles_enabled platform_firewall_services_firewall_services_profiles_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e firewall_services_profiles_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: firewall_services_definitions -> platform_firewall_services_firewall_services_definitions'
grep -R -l -w -e firewall_services_definitions $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" firewall_services_definitions platform_firewall_services_firewall_services_definitions > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e firewall_services_definitions $EXCLUDES .) || true
echo '---'
echo 'Mapping: firewall_zone -> platform_firewall_services_firewall_zone'
grep -R -l -w -e firewall_zone $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" firewall_zone platform_firewall_services_firewall_zone > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e firewall_zone $EXCLUDES .) || true
echo 'Preview complete.'
