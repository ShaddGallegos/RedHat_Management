#!/usr/bin/env bash
# Preview script for role: platform_infrastructure_prep
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

echo 'Role: platform_infrastructure_prep'
echo 'Mappings:'
echo '  infrastructure_prep_enabled -> platform_infrastructure_prep_infrastructure_prep_enabled'
echo '  infrastructure_prep_version -> platform_infrastructure_prep_infrastructure_prep_version'
echo '  infrastructure_prep_timeout -> platform_infrastructure_prep_infrastructure_prep_timeout'
echo '  configure_firewall -> platform_infrastructure_prep_configure_firewall'
echo '  enable_selinux -> platform_infrastructure_prep_enable_selinux'
echo '  infrastructure_prep_validate_network -> platform_infrastructure_prep_infrastructure_prep_validate_network'
echo '
Searching for occurrences and showing diffs (no files modified)...'
echo '---'
echo 'Mapping: infrastructure_prep_enabled -> platform_infrastructure_prep_infrastructure_prep_enabled'
grep -R -l -w -e infrastructure_prep_enabled $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_prep_enabled platform_infrastructure_prep_infrastructure_prep_enabled > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_prep_enabled $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_prep_version -> platform_infrastructure_prep_infrastructure_prep_version'
grep -R -l -w -e infrastructure_prep_version $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_prep_version platform_infrastructure_prep_infrastructure_prep_version > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_prep_version $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_prep_timeout -> platform_infrastructure_prep_infrastructure_prep_timeout'
grep -R -l -w -e infrastructure_prep_timeout $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_prep_timeout platform_infrastructure_prep_infrastructure_prep_timeout > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_prep_timeout $EXCLUDES .) || true
echo '---'
echo 'Mapping: configure_firewall -> platform_infrastructure_prep_configure_firewall'
grep -R -l -w -e configure_firewall $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" configure_firewall platform_infrastructure_prep_configure_firewall > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e configure_firewall $EXCLUDES .) || true
echo '---'
echo 'Mapping: enable_selinux -> platform_infrastructure_prep_enable_selinux'
grep -R -l -w -e enable_selinux $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" enable_selinux platform_infrastructure_prep_enable_selinux > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e enable_selinux $EXCLUDES .) || true
echo '---'
echo 'Mapping: infrastructure_prep_validate_network -> platform_infrastructure_prep_infrastructure_prep_validate_network'
grep -R -l -w -e infrastructure_prep_validate_network $EXCLUDES . || true
while IFS= read -r file; do
  python3 "$TMPDIR/replace.py" "$file" infrastructure_prep_validate_network platform_infrastructure_prep_infrastructure_prep_validate_network > "$TMPDIR/modified" || true
  if ! diff -u "$file" "$TMPDIR/modified" >/dev/null; then
    echo 'Diff for:' "$file"
    diff -u "$file" "$TMPDIR/modified" || true
  fi
done < <(grep -R -l -w -e infrastructure_prep_validate_network $EXCLUDES .) || true
echo 'Preview complete.'
