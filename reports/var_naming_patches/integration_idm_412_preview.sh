#!/usr/bin/env bash
# Preview script for role: integration_idm_412
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

echo 'Role: integration_idm_412'
echo 'Mappings:'
echo '  idm_integration_enabled -> integration_idm_412_idm_integration_enabled'
echo '  idm_integration_version -> integration_idm_412_idm_integration_version'
echo '  idm_integration_timeout -> integration_idm_412_idm_integration_timeout'
echo '  configure_ldap -> integration_idm_412_configure_ldap'
echo '  enable_kerberos -> integration_idm_412_enable_kerberos'
echo '  idm_integration_validate_connectivity -> integration_idm_412_idm_integration_validate_connectivity'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: idm_integration_enabled -> integration_idm_412_idm_integration_enabled'
grep -R -l -w -e idm_integration_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" idm_integration_enabled integration_idm_412_idm_integration_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e idm_integration_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: idm_integration_version -> integration_idm_412_idm_integration_version'
grep -R -l -w -e idm_integration_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" idm_integration_version integration_idm_412_idm_integration_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e idm_integration_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: idm_integration_timeout -> integration_idm_412_idm_integration_timeout'
grep -R -l -w -e idm_integration_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" idm_integration_timeout integration_idm_412_idm_integration_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e idm_integration_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_ldap -> integration_idm_412_configure_ldap'
grep -R -l -w -e configure_ldap $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_ldap integration_idm_412_configure_ldap > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_ldap $EXCLUDES .) || true
echo '---'
echo 'Mapping: enable_kerberos -> integration_idm_412_enable_kerberos'
grep -R -l -w -e enable_kerberos $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" enable_kerberos integration_idm_412_enable_kerberos > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e enable_kerberos $EXCLUDES .) || true
echo '---'
echo 'Mapping: idm_integration_validate_connectivity -> integration_idm_412_idm_integration_validate_connectivity'
grep -R -l -w -e idm_integration_validate_connectivity $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" idm_integration_validate_connectivity integration_idm_412_idm_integration_validate_connectivity > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e idm_integration_validate_connectivity $EXCLUDES .) || true
echo 'Preview complete.'
